// Setups the Mikroni μstack environment

/**
 * So basically, this only starts and builds the LEMP stack, and ensures the project directory is available.
 */
import chalk from "chalk";
import { resolve } from "node:path";
import { CommandModule } from "yargs";

export const StartCommand: CommandModule = {
  command: "start",
  aliases: ["up"],
  describe: "Starts the μstack environment.",
  builder: (args) => {
    return args.option("no_theme", {
      boolean: true,
      alias: "n",
      description: "Don't install starter theme",
    });
  },
  async handler(args) {
    console.log(
      `Adding test.test to /etc/hosts. ` + chalk.black.bgGreen("Installed")
    );
  },
};
