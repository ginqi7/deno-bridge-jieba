import { DenoBridge } from "https://deno.land/x/denobridge@0.0.1/mod.ts";
import {
  type Token,
  tokenize,
} from "./deno-jieba/mod.ts";

const bridge = new DenoBridge(
  Deno.args[0],
  Deno.args[1],
  Deno.args[2],
  messageDispatcher
);

interface Sentence {
  raw: string;
  tokens: Token[];
}
let sentence: Sentence;

function parseSentence(message: string) {
  if (sentence == undefined ||
      sentence.raw != message) {
    sentence = {
      raw: message,
      tokens: tokenize(message),
    };
  }
}

function messageDispatcher(message: string) {
  const info = JSON.parse(message);
  const cmd = info[1][0].trim();
  const sentenceStr = info[1][1];
  const currentColumn = info[1][2];
  parseSentence(sentenceStr);
  // console.log(sentence);
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
  for (let i = 0; i < tokens.length; i++) {
    const token: Token = tokens[i];
    const emacsCmd = `(deno-bridge-jieba-kill-from ${column} ${token.end})`;
    if (column >= token.start && column < token.end) {
      runAndLog(emacsCmd);
      return;
    }
  }
}

function backwardKillWord(column: number) {
  const tokens = sentence.tokens;
  for (let i = 0; i < tokens.length; i++) {
    const token: Token = tokens[i];
    const emacsCmd = `(deno-bridge-jieba-kill-from ${token.start} ${column})`;
    if (column > token.start && column <= token.end) {
      runAndLog(emacsCmd);
      return;
    }
  }
}

function markWord(column: number) {
  const tokens = sentence.tokens;
  for (let i = 0; i < tokens.length; i++) {
    const start = tokens[i].start;
    const end = tokens[i].end;
    if (column >= start && column < end) {
      // mark work from start to end.
      const emacsCmd = `(deno-bridge-jieba-mark-from ${start} ${end})`;
      runAndLog(emacsCmd);
      return;
    }
  }
}

function forwardWord(column: number) {
  const tokens = sentence.tokens;
  for (let i = 0; i < tokens.length; i++) {
    const token = tokens[i];
    if (column >= token.start && column < token.end) {
      // jump to word end
      const movePosition = token.end;
      const emacsCmd = `(deno-bridge-jieba-goto ${movePosition})`;
      runAndLog(emacsCmd);
      return;
    }
  }
}

function bacwardWord(column: number) {
  const tokens = sentence.tokens;
  for (let i = 0; i < tokens.length; i++) {
    const start = tokens[i].start;
    const end = tokens[i].end;
    let movePosition: number;

    if (column > start && column <= end) {
      // when current column is in the middle of a word
      // jump to word beginning
      movePosition = start;
      const emacsCmd = `(deno-bridge-jieba-goto ${movePosition})`;
      runAndLog(emacsCmd);
      return;
    } else if (column == start) {
      // when current column is in the beginning of a word
      // jump to pre word beginning
      movePosition = i == 0 ? 0 : tokens[i - 1].start;
      const emacsCmd = `(deno-bridge-jieba-goto ${movePosition})`;
      runAndLog(emacsCmd);
      return;
    }
  }
}

function runAndLog(cmd: string) {
  console.log(cmd);
  bridge.evalInEmacs(cmd);
}
