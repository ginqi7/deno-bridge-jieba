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
;;
;;; Customizable Options:
;;
;; Below are customizable option list:
;;

;;; Code:

(require 'deno-bridge)
(setq deno-bridge-demo-ts-path (concat (file-name-directory load-file-name) "deno-bridge-jieba.ts"))

(defun deno-bridge-jieba-start ()
  "Start deno bridge jieba."
  (interactive)
  (deno-bridge-start "deno-bridge-jieba" deno-bridge-demo-ts-path))

(defun deno-bridge-jieba-restart ()
  "Restart deno bridge jieba and show process."
  (interactive)
  (deno-bridge-exit)
  (deno-bridge-jieba-start)
  (list-processes))

(defun deno-bridge-jieba-forward-word ()
  "Send request to deno for forward chinese word."
  (interactive)
  (if (or (= (line-end-position) (point)) ;; if current point is line end, just forward-word
          ;; if following char is single width, is ASCII char, just forward-word
          (deno-bridge-jieba-single-width-char?))
      (forward-word) 
    (deno-bridge-call "deno-bridge-jieba" "forward-word"
                      (thing-at-point 'line)
                      (- (point) (line-beginning-position)))))

(defun deno-bridge-jieba-backward-word ()
  "Send request to deno for backward chinese word."
  (interactive)
  (if (or (= (line-beginning-position) (point)) ;; if current point is line beginning, just backward-word
          ;; if following char is single width, is ASCII char, just backward-word
          (deno-bridge-jieba-single-width-char?))
      (backward-word) 
  (deno-bridge-call "deno-bridge-jieba" "backward-word"
                    (thing-at-point 'line)
                    (- (point) (line-beginning-position)))))


(defun deno-bridge-jieba-mark-word ()
  "Send request to deno for mark chinese word."
  (interactive)
  (deno-bridge-call "deno-bridge-jieba" "mark-word"
                    (thing-at-point 'line)
                    (- (point) (line-beginning-position))))

(defun deno-bridge-jieba-kill-word ()
  "Send request to deno for kill chinese word."
  (interactive)
  (deno-bridge-call "deno-bridge-jieba" "kill-word"
                    (thing-at-point 'line)
                    (- (point) (line-beginning-position))))

(defun deno-bridge-jieba-kill-from (begin end)
  "Send request to deno for killing char on between BEGIN and END."
  (kill-region
   (+ (line-beginning-position) begin)
   (+ (line-beginning-position) end)))

(defun deno-bridge-jieba-mark-from (begin end)
  "Send request to deno for marking char on between BEGIN and END."
  (set-mark (+ (line-beginning-position) begin))
  (goto-char (+ (line-beginning-position) end)))


(defun deno-bridge-jieba-goto (num)
  "Send request to deno for goto char on current line by NUM."
  (beginning-of-line)
  (forward-char num))

(defun deno-bridge-jieba-single-width-char? ()
  "Check following char if a single width char."
  (= (string-width (string (following-char))) 1))

(deno-bridge-jieba-start) ;; start deno-bridge-jieba when load package.
(provide 'deno-bridge-jieba)
;;; deno-bridge-jieba.el ends here
