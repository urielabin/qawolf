import { logger } from "@qawolf/logger";
import { FindElementOptions, HtmlSelector } from "@qawolf/types";
import { QAWolfWeb } from "@qawolf/web";
import { ElementHandle, Page, Serializable } from "puppeteer";

export const findHtml = async (
  page: Page,
  selector: HtmlSelector,
  options: FindElementOptions
): Promise<ElementHandle<Element>> => {
  logger.verbose("findHtml");

  const jsHandle = await page.evaluateHandle(
    (selector, options) => {
      const qawolf: QAWolfWeb = (window as any).qawolf;
      const findCmd = () => qawolf.find.findHtml(selector, options);
      // store the last find on the window for easy debugging
      (window as any).qaw_find = findCmd;
      return findCmd();
    },
    selector as any,
    options as Serializable
  );

  const element = jsHandle.asElement();
  if (!element) throw new Error("Element not found");

  return element;
};
