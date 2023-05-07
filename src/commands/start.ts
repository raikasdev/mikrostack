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
  async handler(args) {
    // TODO: implement
  },
};
