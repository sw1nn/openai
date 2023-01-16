;;; openai.el --- Elisp library for the OpenAI API  -*- lexical-binding: t; -*-

;; Copyright (C) 2023  Shen, Jen-Chieh

;; Author: Shen, Jen-Chieh <jcs090218@gmail.com>
;; Maintainer: Shen, Jen-Chieh <jcs090218@gmail.com>
;; URL: https://github.com/jcs090218/openai
;; Version: 0.1.0
;; Package-Requires: ((emacs "26.1") (request "0.3.0") (tblui "0.1.0"))
;; Keywords: comm openai

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Elisp library for the OpenAI API
;;

;;; Code:

(require 'cl-lib)
(require 'let-alist)
(require 'pp)

(require 'request)
(require 'tblui)

(defgroup openai nil
  "Elisp library for the OpenAI API."
  :prefix "openai-"
  :group 'comm
  :link '(url-link :tag "Repository" "https://github.com/jcs090218/openai"))

(defcustom openai-key ""
  "Generated API key."
  :type 'list
  :group 'openai)

(defcustom openai-user ""
  "A unique identifier representing your end-user, which can help OpenAI to
monitor and detect abuse."
  :type 'string
  :group 'openai)

(defmacro openai-request (url &rest body)
  "Wrapper for `request' function."
  (declare (indent 1))
  `(if (string-empty-p openai-key)
       (user-error "[INFO] Invalid API key, please set it to the correct value: %s" openai-key)
     (request ,url ,@body)))

;;
;;; Util

(defcustom openai-annotation-ratio 2.5
  "Ratio align from the right to display `completin-read' annotation."
  :type 'float
  :group 'openai)

(defun openai--2str (obj)
  "Convert OBJ to string."
  (format "%s" obj))

(defun openai--seq-str-max (sequence)
  "Return max length in list of strings."
  (let ((result 0))
    (mapc (lambda (elm) (setq result (max result (length (openai--2str elm))))) sequence)
    result))

(defun openai--completing-frame-offset (options)
  "Return frame offset while `completing-read'.

Argument OPTIONS ia an alist use to calculate the frame offset."
  (max (openai--seq-str-max (mapcar #'cdr options))
       (/ (frame-width) openai-annotation-ratio)))

(defmacro openai--with-buffer (buffer-or-name &rest body)
  "Execute BODY ensure the buffer is alive."
  (declare (indent 1))
  `(when (buffer-live-p ,buffer-or-name)
     (with-current-buffer ,buffer-or-name ,@body)))

(defun openai--pop-to-buffer (buffer-or-name)
  "Show ChatGPT display buffer."
  (pop-to-buffer (get-buffer-create buffer-or-name)
                 `((display-buffer-in-direction)
                   (dedicated . t))))

(provide 'openai)
;;; openai.el ends here
