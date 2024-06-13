;;; deno-bridge-jieba.el --- jieba for deno-bridge   -*- lexical-binding: t; -*-

;; Copyright (C) 2022  Qiqi Jin

;; Author: Qiqi Jin <ginqi7@gmail.com>
;; Keywords: lisp

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Commands:
;;
;; Below are complete command list:
;;
;;  `deno-bridge-jieba-start'
;;    Start deno bridge jieba.
;;  `deno-bridge-jieba-restart'
;;    Restart deno bridge jieba and show process.
;;  `deno-bridge-jieba-forward-word'
;;    Send request to deno for forward chinese word.
;;  `deno-bridge-jieba-backward-word'
;;    Send request to deno for backward chinese word.
;;  `deno-bridge-jieba-mark-word'
;;    Send request to deno for mark chinese word.
;;  `deno-bridge-jieba-kill-word'
;;    Send request to deno for kill chinese word.
;;  `deno-bridge-jieba-backward-kill-word'
;;    Send request to deno for kill chinese word backward.
;;
;;; Customizable Options:
;;
;; Below are customizable option list:
;;

;;; Code:

(require 'deno-bridge)

(defvar deno-bridge-jieba-ts-path
      (concat
       (file-name-directory load-file-name)
       "deno-bridge-jieba.ts"))

(defun deno-bridge-call-jieba-on-current-line(func-name)
  "Call jieba function on current line by FUNC-NAME."
  (deno-bridge-call "deno-bridge-jieba" func-name
                    (thing-at-point 'line nil)
                    (- (point) (line-beginning-position))))

(defun deno-bridge-jieba-backward-kill-word ()
  "Send request to deno for kill chinese word backward."
  (interactive)
  (cond
   ((or
     (deno-bridge-jieba-blank-before-cursor-p)
     (deno-bridge-jieba-punctuation-char-before-cursor-p))
    (backward-delete-char 1))
   ((deno-bridge-jieba-single-char-before-cursor-p)
    (backward-kill-word 1))
   (t (deno-bridge-call-jieba-on-current-line "backward-kill-word"))))

(defun deno-bridge-jieba-backward-word ()
  "Send request to deno for backward chinese word."
  (interactive)
  (cond
   ((= (line-beginning-position) (point))
    (backward-word))
   ((deno-bridge-jieba-blank-before-cursor-p)
    (search-backward-regexp "\\s-+" nil (point-at-bol)))
   ((deno-bridge-jieba-punctuation-char-before-cursor-p)
    (search-backward-regexp "[[:punct:]]+" nil (point-at-eol)))
   ((deno-bridge-jieba-single-char-before-cursor-p)
    (backward-word))
   (t (deno-bridge-call-jieba-on-current-line "backward-word"))))

(defun deno-bridge-jieba-blank-after-cursor-p ()
  "Have blank after cursor."
  (not (split-string
        (buffer-substring-no-properties
         (min (1+ (point)) (point-at-eol))
         (point)))))

(defun deno-bridge-jieba-blank-before-cursor-p ()
  "Have blank before cursor."
  (not (split-string
        (buffer-substring-no-properties
         (max (1- (point)) (line-beginning-position))
         (point)))))

(defun deno-bridge-jieba-forward-word ()
  "Send request to deno for forward chinese word."
  (interactive)
  (cond
   ((= (line-end-position) (point))
    (forward-word))
   ((deno-bridge-jieba-blank-after-cursor-p)
    (search-forward-regexp "\\s-+" nil (point-at-eol)))
   ((deno-bridge-jieba-punctuation-char-after-cursor-p)
    (search-forward-regexp "[[:punct:]]+" nil (point-at-eol)))
   ((deno-bridge-jieba-single-char-after-cursor-p)
    (forward-word))
   (t (deno-bridge-call-jieba-on-current-line "forward-word"))))

(defun deno-bridge-jieba-goto (num)
  "Send request to deno for goto char on current line by NUM."
  (beginning-of-line)
  (forward-char num))

(defun deno-bridge-jieba-kill-from (begin end)
  "Send request to deno for killing char on between BEGIN and END."
  (kill-region
   (+ (line-beginning-position) begin)
   (+ (line-beginning-position) end)))

(defun deno-bridge-jieba-kill-word ()
  "Send request to deno for kill chinese word."
  (interactive)
  (cond
   ((or
     (deno-bridge-jieba-blank-after-cursor-p)
     (deno-bridge-jieba-punctuation-char-after-cursor-p))
    (delete-char 1))
   ((deno-bridge-jieba-single-char-after-cursor-p)
    (kill-word 1))
   (t (deno-bridge-call-jieba-on-current-line "kill-word"))))

(defun deno-bridge-jieba-mark-from (begin end)
  "Send request to deno for marking char on between BEGIN and END."
  (set-mark (+ (line-beginning-position) begin))
  (goto-char (+ (line-beginning-position) end)))

(defun deno-bridge-jieba-mark-word ()
  "Send request to deno for mark chinese word."
  (interactive)
  (deno-bridge-call-jieba-on-current-line "mark-word"))

(defun deno-bridge-jieba-punctuation-char-after-cursor-p ()
  "Check following char if a punctuation."
  (deno-bridge-jieba-punctuation-char-p (string (char-after))))

(defun deno-bridge-jieba-punctuation-char-before-cursor-p ()
  "Check before char if a punctuation."
  (deno-bridge-jieba-punctuation-char-p (string (char-before))))

(defun deno-bridge-jieba-punctuation-char-p (char)
  "Check if the CHAR is a punct."
  (string-match "[[:punct:]]+" char))

(defun deno-bridge-jieba-restart ()
  "Restart deno bridge jieba and show process."
  (interactive)
  (deno-bridge-exit)
  (deno-bridge-jieba-start)
  (list-processes))

(defun deno-bridge-jieba-single-char-after-cursor-p ()
  "Check following char if a single width char."
  (= (string-width (string (char-after))) 1))

(defun deno-bridge-jieba-single-char-before-cursor-p ()
  "Check before char if a single width char."
  (= (string-width (string (char-before))) 1))

(defun deno-bridge-jieba-start ()
  "Start deno bridge jieba."
  (interactive)
  (deno-bridge-start "deno-bridge-jieba" deno-bridge-jieba-ts-path))

(deno-bridge-jieba-start) ;; start deno-bridge-jieba when load package.
(provide 'deno-bridge-jieba)
;;; deno-bridge-jieba.el ends here
