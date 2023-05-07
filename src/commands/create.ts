// Creates a new Mikroni μstack project

/**
 * So basically:
 * Creates a Bedrock project
 * Create a database
 * Installing plugins and removing default themes
 * Configuring .env
 * Setupping and configuring WP using WP-CLI
 * Creates SSL certificates
 * Adds entry to /etc/hosts
 * Adds an entry to mikrostack.code-workspace
 * TODO: Create an empty page and set home page to it
 */
import { FileBlob, SpawnOptions } from "bun";
import { CommandModule } from "yargs";
import { PromptOptions, createPrompt } from "bun-promptx";
import { resolve } from "node:path";
import chalk from "chalk";

const NAME_REGEX = /^[a-z0-9-]+$/;
const plugins = ["imagify", "autodescription"]; // TODO: maybe move to some config file

export const CreateCommand: CommandModule = {
  command: "create <id>",
  aliases: ["new"],
  describe: "Creates a new μstack project.",
  builder: (args) => {
    return args
      .positional("id", {
        description:
          "The id of the project in lowercase without any special characters",
      })
      .option("no_theme", {
        boolean: true,
        alias: "n",
        description: "Don't install starter theme",
      });
  },
  async handler(args) {
    const siteId = args.id as string;

    // Check if it is in right format
    if (!NAME_REGEX.test(siteId)) {
      console.error(
        "The project id can only include lowercase letters, numbers and hyphens."
      );
      return;
    }

    // Check if user config is set
    if (!checkEnv()) {
      console.log(
        "User environment was not found. The following questions will only be asked only once."
      );
      const mysqlRootPwd =
        prompt(
          "What is the MySQL root password (default: mikrostack)? ",
          {},
          false
        ) || "mikrostack";
      const wpAdminUsername = prompt(
        "What is the admin username you want to use for wp-admin? "
      );
      const wpAdminEmail = prompt(
        "What is the admin email address you want to use for wp-admin? "
      );
      const wpAdminPassword = prompt(
        "What is the admin password you want to use for wp-admin? ",
        {
          echoMode: "password",
        }
      );
      Bun.write(
        "./.env",
        `MYSQL_ROOT_PASSWORD=${mysqlRootPwd}\nWP_ADMIN_USERNAME=${wpAdminUsername}\nWP_ADMIN_EMAIL=${wpAdminEmail}\nWP_ADMIN_PASSWORD=${wpAdminPassword}`
      );
      process.env.MYSQL_ROOT_PASSWORD = mysqlRootPwd;
      process.env.WP_ADMIN_USERNAME = wpAdminUsername;
      process.env.WP_ADMIN_PASSWORD = wpAdminPassword;
      process.env.WP_ADMIN_EMAIL = wpAdminEmail;

      console.log("Settings have been saved to the environment file.\n");
    }

    // Ask for styled site name (if id is jaatelokioski, this could be Jäätelökioski)
    const siteName = prompt("Enter site name (stylized) ");
    // The first thing we want to do is to create the datatabase to ensure
    // that docker is running

    const rootDir = resolve(import.meta.dir, "../..");
    const scriptsDir = resolve(rootDir, "./scripts");

    const res = await runCommand(
      [
        "bash",
        resolve(scriptsDir, "create-db.sh"),
        process.env.MYSQL_ROOT_PASSWORD,
        siteId,
      ],
      {
        stdout: args.verbose === true ? "inherit" : "pipe",
      }
    );
    if (args.verbose) console.log(res);
    if (res.includes("is not running")) {
      // Docker hasn't been started
      console.error("μstack is not running. Please run `wp start` first.");
      return;
    }

    const projectsDir = resolve(rootDir, "projects");
    const projectDir = resolve(projectsDir, `./${siteId}`);

    console.log("Creating project using Composer...");
    // Create the project using composer
    await runCommand(
      ["composer", "create-project", "-n", "roots/bedrock", projectDir],
      {
        stdout: args.verbose === true ? "inherit" : "pipe",
      }
    );

    // Lets just install acorn here. For some reason it install 2.1 instead of 3.1 in other places
    const acornRes = await runCommand(["composer", "require", "roots/acorn"], {
      cwd: projectDir,
      stdout: args.verbose === true ? "inherit" : "pipe",
    });

    if (args.verbose) console.log(acornRes);

    // Add to /etc/hosts using script
    console.log(
      `Adding ${siteId}.test to /etc/hosts. ` +
        chalk.black.bgYellowBright(
          "This might require you to authenticate for sudo!"
        )
    );
    const { success } = await Bun.spawnSync(
      ["bash", resolve(scriptsDir, "add-host.sh"), `${siteId}.test`],
      {
        stdout: args.verbose === true ? "inherit" : "pipe",
      }
    );
    if (!success) {
      console.error("Adding to /etc/hosts failed");
      console.log(
        "Please add the following line manually to end of /etc/hosts:"
      );
      console.log(`127.0.0.1 ${siteId}.test`);
    }

    // Good, lets add plugins and WP-CLI
    console.log("Installing composer dependencies...");
    const composerRes = await runCommand(
      [
        "composer",
        "require",
        "wp-cli/wp-cli-bundle",
        ...plugins.map((i) => `wpackagist-plugin/${i}`),
      ],
      {
        cwd: projectDir,
        stdout: args.verbose === true ? "inherit" : "pipe",
      }
    );

    if (args.verbose) console.log(composerRes);

    // Lets run composer update
    await runCommand(["composer", "update"], {
      cwd: projectDir,
      stdout: args.verbose === true ? "inherit" : "pipe",
    });

    // Also lets remove stuff we don't need (the default theme)
    await runCommand(
      ["composer", "remove", "wpackagist-theme/twentytwentythree"],
      {
        cwd: projectDir,
        stdout: args.verbose === true ? "inherit" : "pipe",
      }
    );

    // Lets replace variables in the .env for WPCLI
    const env = Bun.file(resolve(projectDir, ".env"));
    await fileReplace(env, [
      [/database_name/g, siteId],
      [/database_user/g, "root"],
      [/database_password/g, process.env.MYSQL_ROOT_PASSWORD || "mikrostack"],
      [/example\.com/g, `${siteId}.test`],
      [/http/g, "https"],
      [/# DB_HOST='localhost'/g, "DB_HOST='127.0.0.1'"],
    ]);

    console.log("Installing WordPress...");
    Bun.write(
      resolve(projectDir, "wp-cli.yml"),
      `path: web/wp
url: https://${siteId}.test

core install:
  admin_user: "${process.env.WP_ADMIN_USERNAME}"
  admin_password: "${process.env.WP_ADMIN_PASSWORD}"
  admin_email: "${process.env.WP_ADMIN_EMAIL}"
  title: "${siteName}"`
    );

    await runCommand(
      [
        "bash",
        "vendor/wp-cli/wp-cli/bin/wp",
        "core",
        "install",
        `--title="${siteName}"`,
        `--admin_email=${process.env.WP_ADMIN_EMAIL}`,
      ],
      {
        cwd: projectDir,
        stdout: args.verbose === true ? "inherit" : "pipe",
      }
    );

    console.log("Setting WP-CLI settings...");
    const options = [
      "post delete 1 --force",
      "post delete 2 --force",
      "option update blogdescription ''",
      "option update WPLANG 'fi'",
      "option update current_theme '$1'",
      "theme delete twentytwelve",
      "theme delete twentythirteen",
      "option update permalink_structure '/%postname%'",
      "option update timezone_string 'Europe/Helsinki'",
      "option update default_pingback_flag '0'",
      "option update default_ping_status 'closed'",
      "option update default_comment_status 'closed'",
      "option update date_format 'j.n.Y'",
      "option update time_format 'H.i'",
      `option update admin_email '${process.env.WP_ADMIN_EMAIL}'`,
      "option delete new_admin_email",
      "plugin activate --all",
      "post create --post_title=Etusivu --post_status=publish --post_type=page",
      "option update show_on_front 'page'",
      "option update page_on_front 3",
    ];

    for (const option of options) {
      await runCommand(
        ["bash", "vendor/wp-cli/wp-cli/bin/wp", ...option.split(" ")],
        {
          cwd: projectDir,
          stdout: args.verbose === true ? "inherit" : "pipe",
        }
      );
    }

    if (!args.no_theme) {
      // Install Sage starter theme
      // TODO: create own starter theme (Sage with basic navigation and footer, and other preferences)
      // Also that uses bund (bud with bun) for ultra fast builds
      console.log("Creating theme...");
      const themeDir = resolve(projectDir, `web/app/themes/${siteId}`);
      await runCommand(
        [
          "composer",
          "create-project",
          "-n",
          "roots/sage",
          themeDir,
          "dev-main",
        ],
        {
          cwd: projectDir,
          stdout: args.verbose === true ? "inherit" : "pipe",
        }
      );

      // Installing acorn

      const file = Bun.file(resolve(projectDir, "composer.json"));
      const composerJson = await file.json();
      composerJson.scripts = composerJson.scripts || {};
      composerJson.scripts["post-autoload-dump"] =
        composerJson.scripts["post-autoload-dump"] || [];
      composerJson.scripts["post-autoload-dump"].push(
        "Roots\\Acorn\\ComposerScripts::postAutoloadDump"
      );
      await Bun.write(file, JSON.stringify(composerJson, null, 2));

      await runCommand(["composer", "update"], {
        cwd: projectDir,
        stdout: args.verbose === true ? "inherit" : "pipe",
      });

      // Config replacer
      await fileReplace(Bun.file(resolve(themeDir, "bud.config.js")), [
        [/http:\/\/example\.test/g, `https://${siteId}.test`],
      ]);

      console.log("Setupping and building theme...");

      await runCommand(
        ["bash", resolve(scriptsDir, "setup-theme.sh"), siteId],
        {
          stdout: args.verbose === true ? "inherit" : "pipe",
        }
      );

      // Activate theme
      await runCommand(
        ["bash", "vendor/wp-cli/wp-cli/bin/wp", "theme", "activate", siteId],
        {
          cwd: projectDir,
          stdout: args.verbose === true ? "inherit" : "pipe",
        }
      );
      console.log("Theme created.");
    }

    // Copying NGINX template
    console.log("Copying NGINX template...");
    const nginxDir = resolve(rootDir, "./nginx");
    const config = Bun.file(resolve(nginxDir, `sites/${siteId}.conf`));
    await Bun.write(config, Bun.file(resolve(nginxDir, "_template.conf")));
    await fileReplace(config, [[/PROJECT_NAME/g, siteId]]);

    // Generate SSL certs
    console.log("Generating SSL certs...");
    const { success: sslSuccess } = await Bun.spawnSync(
      ["bash", resolve(scriptsDir, "generate-certs.sh"), siteId],
      {
        stdout: args.verbose === true ? "inherit" : "pipe",
      }
    );
    if (!sslSuccess) {
      console.error("Generating SSL certs failed");
      console.log(`Please run \`sudo scripts/generate-certs.sh ${siteId}\``);
    }

    // Finally replace it with docker database network name
    await fileReplace(env, [[/DB_HOST='127\.0\.0\.1'/g, "DB_HOST='db'"]]);

    // Set perms
    await runCommand(["mkdir", "-p", resolve(projectDir, "web/app/cache")], {
      cwd: projectDir,
    });

    const permRes = await runCommand(
      ["chmod", "-R", "777", resolve(projectDir, "web/app/cache")],
      {
        cwd: projectDir,
      }
    );

    if (args.verbose) console.log(permRes);

    // Finally, restart nginx
    await runCommand(["docker", "compose", "restart", "nginx"], {
      cwd: rootDir,
    });

    console.log(chalk.black.bgGreen("WordPress installation complete!"));

    // Let's add it to code workspace
    const workspaceFile = Bun.file(resolve(rootDir, "projects.code-workspace"));
    const workspace =
      workspaceFile.size !== 0 ? await workspaceFile.json() : { folders: [] };
    workspace.folders.push({
      name: `🖌️ ${siteId}`,
      path: `./projects/${siteId}/web/app/themes/${siteId}`,
    });
    await Bun.write(workspaceFile, JSON.stringify(workspace, null, 2));
    return;
  },
};

function checkEnv() {
  return (
    process.env.MYSQL_ROOT_PASSWORD &&
    process.env.WP_ADMIN_USERNAME &&
    process.env.WP_ADMIN_PASSWORD &&
    process.env.WP_ADMIN_EMAIL
  );
}

async function fileReplace(file: FileBlob, replacer: [RegExp, string][]) {
  let content = await file.text();
  for (const [regex, to] of replacer) {
    content = content.replaceAll(regex, to);
  }
  Bun.write(file, content);
}

function prompt(
  promptText: string,
  options?: PromptOptions,
  quitOnEmpty = true
): string {
  const value = createPrompt(promptText, {
    required: true,
    ...options,
  });
  if ((value.value === "" || value.error) && quitOnEmpty) {
    console.error("Invalid response. Quitting.");
    process.exit(-1); // This library returns an empty value if the user does CTRL+C, so better to just quit that retrying
  }
  return value.value || "";
}

async function runCommand(
  cmds: [string, ...string[]],
  options?: SpawnOptions.OptionsObject
) {
  const { stdout, stderr } = Bun.spawnSync(cmds, options);

  return (
    (stderr?.length !== 0
      ? stderr?.toString("utf-8")
      : stdout?.toString("utf-8")) || ""
  );
}
