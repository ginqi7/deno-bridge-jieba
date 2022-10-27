import { DenoBridge } from "https://deno.land/x/denobridge@0.0.1/mod.ts";
import { cut } from "https://cdn.jsdelivr.net/gh/wangbinyq/deno-jieba@wasm/mod.ts";

const bridge = new DenoBridge(
  Deno.args[0],
  Deno.args[1],
  Deno.args[2],
  messageDispatcher
);

const sentence = {
  raw: "",
  words: [],
  position: [],
};

async function parseSentence(message: string) {
  if (sentence.raw == undefined || sentence.raw != message) {
    sentence.raw = message;
    sentence.words = await cut(message);
    sentence.position = computePosition(sentence.words);
    console.log(sentence.raw);
    console.log(sentence.words);
  }
}

function computePosition(words: string[]) {
  var begin = 0;
  var position = [];
  for (var i = 0; i < words.length; i++) {
    var end = begin + words[i].replace(/[^\x00-\xff]/g, "__").length; // chinese two width, ascii one width
    position.push([begin, end]);
    begin = end;
  }
  return position;
}

async function messageDispatcher(message: string) {
  const info = JSON.parse(message);
  const cmd = info[1][0].trim();
  const sentenceStr = info[1][1];
  const currentColumn = info[1][2];
    await parseSentence(sentenceStr);
    if (cmd == "forward-word") {
        forwardWord(currentColumn);
    } else if (cmd == "bacward-word") {
        bacwardWord(currentColumn);
    } else if (cmd == "mark-word") {
        markWord(currentColumn);
    } else if (cmd == "kill-word") {
        killWord(currentColumn);
    }
}

function killWord(column: number) {
    const position = sentence.position;
    for (var i = 0; i < position.length; i++) {
        const positionRight = position[i][1];
        const positionLeft = position[i][0];
        if (column >= positionLeft && column < positionRight) {
            // mark work from begin to end.
            var emacsCmd = `(save-excursion \
  (let ((begin (progn (move-to-column ${positionLeft}) (point))) \
        (end (progn (move-to-column ${positionRight}) (point)))) \
    (kill-region begin end)))
`;
            console.log(emacsCmd);
            bridge.evalInEmacs(emacsCmd);
            return;
        }
    }
} 

function markWord(column: number) {
  const position = sentence.position;
  for (var i = 0; i < position.length; i++) {
    const positionRight = position[i][1];
    const positionLeft = position[i][0];
    if (column >= positionLeft && column < positionRight) {
      // mark work from begin to end.
      var emacsCmd = `(progn \
(move-to-column ${positionLeft}) \
(set-mark (save-excursion (move-to-column ${positionRight}) (point)))) `;
      console.log(emacsCmd);
      bridge.evalInEmacs(emacsCmd);
      return;
    }
  }
}

function forwardWord(column: number) {
  const position = sentence.position;
  for (var i = 0; i < position.length; i++) {
    const positionRight = position[i][1];
    const positionLeft = position[i][0];
    var movePosition: string;
    console.log(position[i]);
    if (column >= positionLeft && column < positionRight) {
      // jump to word right
      movePosition = positionRight;
      var emacsCmd = `(move-to-column ${movePosition})`;
      console.log(emacsCmd);
      bridge.evalInEmacs(emacsCmd);
      return;
    }
  }
}

function bacwardWord(column: number) {
  const position = sentence.position;
  for (var i = 0; i < position.length; i++) {
    const positionRight = position[i][1];
    const positionLeft = position[i][0];
    var movePosition: string;
    if (column > positionLeft && column < positionRight) {
      // when current column is in the middle of a word
      // jump to word beginning
      movePosition = positionLeft;
      var emacsCmd = `(move-to-column ${movePosition})`;
      console.log(emacsCmd);
      bridge.evalInEmacs(emacsCmd);
      return;
    } else if (column == positionLeft) {
      // when current column is in the beginning of a word
      // jump to pre word beginning
      movePosition = i == 0 ? 0 : position[i - 1][0];
      var emacsCmd = `(move-to-column ${movePosition})`;
      console.log(emacsCmd);
      bridge.evalInEmacs(emacsCmd);
      return;
    }
  }
}
