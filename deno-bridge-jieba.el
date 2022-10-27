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

;;; Code:

(require 'deno-bridge)
(setq deno-bridge-demo-ts-path (concat (file-name-directory load-file-name) "deno-bridge-jieba.ts"))

(defun deno-bridge-jieba-start ()
  (interactive)
  (deno-bridge-start "deno-bridge-jieba" deno-bridge-demo-ts-path))

(defun deno-bridge-jieba-restart ()
  (interactive)
  (deno-bridge-exit)
  (deno-bridge-jieba-start)
  (list-processes)
  )

(defun denote-bridge-jieba-parse-current-line ()
  (interactive)
  (deno-bridge-call "deno-bridge-jieba" "parse" (thing-at-point 'line)))

(defun denote-bridge-jieba-forward-word ()
  (interactive)
  (deno-bridge-call "deno-bridge-jieba" "forward-word" (thing-at-point 'line) (current-column)))

(defun denote-bridge-jieba-bacward-word ()
  (interactive)
  (deno-bridge-call "deno-bridge-jieba" "bacward-word" (thing-at-point 'line) (current-column)))


(defun denote-bridge-jieba-mark-word ()
  (interactive)
  (deno-bridge-call "deno-bridge-jieba" "mark-word" (thing-at-point 'line) (current-column)))

(defun denote-bridge-jieba-kill-word ()
  (interactive)
  (deno-bridge-call "deno-bridge-jieba" "kill-word" (thing-at-point 'line) (current-column)))

(defun denote-bridge-jieba-backward-kill-word ()
  (interactive)
  (deno-bridge-call "deno-bridge-jieba" "backward-kill-word" (thing-at-point 'line) (current-column)))

(provide 'deno-bridge-jieba)
;;; deno-bridge-jieba.el ends here

