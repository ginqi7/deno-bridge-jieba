import { DenoBridge } from "https://deno.land/x/denobridge@0.0.1/mod.ts";
import {
  cut,
  tokenize,
} from "https://cdn.jsdelivr.net/gh/wangbinyq/deno-jieba@wasm/mod.ts";

const bridge = new DenoBridge(
  Deno.args[0],
  Deno.args[1],
  Deno.args[2],
  messageDispatcher
);
const sentence = {
  raw: "",
  tokens: [],
};

async function parseSentence(message: string) {
  if (sentence.raw == undefined || sentence.raw != message) {
    sentence.raw = message;
    sentence.tokens = await tokenize(message);
  }
}

async function messageDispatcher(message: string) {
  const info = JSON.parse(message);
  const cmd = info[1][0].trim();
  const sentenceStr = info[1][1];
  const currentColumn = info[1][2];
  await parseSentence(sentenceStr);
  if (cmd == "forward-word") {
    forwardWord(currentColumn);
  } else if (cmd == "backward-word") {
    bacwardWord(currentColumn);
  } else if (cmd == "mark-word") {
    markWord(currentColumn);
  } else if (cmd == "kill-word") {
    killWord(currentColumn);
  } else if (cmd == "backward-kill-word") {
    backwardKillWord(currentColumn);
  }
}

function killWord(column: number) {
  const tokens = sentence.tokens;
  for (var i = 0; i < tokens.length; i++) {
    var token = tokens[i];
    if (column >= token.start && column < token.end) {
      var emacsCmd = `(deno-bridge-jieba-kill-from ${column} ${token.end})`;
      runAndLog(emacsCmd);
      return;
    }
  }
}

function backwardKillWord(column: number) {
  const tokens = sentence.tokens;
  for (let i = 0; i < tokens.length; i++) {
    const token = tokens[i];
    if (column > token.start && column <= token.end) {
      const emacsCmd = `(deno-bridge-jieba-kill-from ${token.start} ${column})`;
      runAndLog(emacsCmd);
      return;
    }
  }
}

function markWord(column: number) {
  var tokens = sentence.tokens;
  for (var i = 0; i < tokens.length; i++) {
    const start = tokens[i].start;
    const end = tokens[i].end;
    if (column >= start && column < end) {
      // mark work from start to end.
      var emacsCmd = `(deno-bridge-jieba-mark-from ${start} ${end})`;
      runAndLog(emacsCmd)
      return;
    }
  }
}

function forwardWord(column: number) {
  const tokens = sentence.tokens;
  for (var i = 0; i < tokens.length; i++) {
    const token = tokens[i];
    if (column >= token.start && column < token.end) {
      // jump to word end
      var movePosition = token.end;
      var emacsCmd = `(deno-bridge-jieba-goto ${movePosition})`;
      runAndLog(emacsCmd)
      return;
    }
  }
}

function bacwardWord(column: number) {
  const tokens = sentence.tokens;
  for (var i = 0; i < tokens.length; i++) {
    const start = tokens[i].start;
    const end = tokens[i].end;
    var movePosition: string;

    if (column > start && column <= end) {
      // when current column is in the middle of a word
      // jump to word beginning
      movePosition = start;
      var emacsCmd = `(deno-bridge-jieba-goto ${movePosition})`;
      runAndLog(emacsCmd)
      return;
    } else if (column == start) {
      // when current column is in the beginning of a word
      // jump to pre word beginning
      movePosition = i == 0 ? 0 : tokens[i - 1].start;
      var emacsCmd = `(deno-bridge-jieba-goto ${movePosition})`;
      runAndLog(emacsCmd)
      return;
    }
  }
}

function runAndLog(cmd: string) {
  console.log(cmd);
  bridge.evalInEmacs(cmd);
}
