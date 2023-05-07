import yargs from "yargs";
import { hideBin } from "yargs/helpers";
import packageJson from "../package.json";
import { StartCommand } from "./commands/start";
import { CreateCommand } from "./commands/create";

// Spoof executable name
process.argv[0] = "wp";

// Run the yargs cli app
yargs(hideBin(process.argv))
  .command(StartCommand)
  .command(CreateCommand)
  .option("verbose", {
    alias: "v",
    type: "boolean",
    description: "Run with verbose logging",
  })
  .demandCommand()
  .strict()
  .version(packageJson.version)
  .parse();
