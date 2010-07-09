;;;; stag.el --- Writing HTML with S-expression

;; Author: Kawaguchi Masaya <masayakawaguchi@gmail.com>
;; Created: 09 Jul 2010
;; Keywords: html, sexp, languages

;;; Code:

(defun stag-attribute-key? (object)
  (and (symbolp object)
       (string-match "^:." (symbol-name object))))

(defun stag-tag? (object)
  (and (symbolp object)
       (not (stag-attribute-key? object))))

(defun stag-element? (object)
  (and (listp object)
       (assoc 'tag object)
       (assoc 'attribute object)
       (assoc 'contents object)))

(defun stag-pick-attributes (list)
  (if (and (listp list)
           (stag-attribute-key? (car list)))
      (let ((key (substring (symbol-name (car list)) 1))
            (value (cadr list)))
        (cons (cons key value) (stag-pick-attributes (cddr list))))))

(defun stag-pick-contents (list)
  (if (and (listp list)
           (stag-attribute-key? (car list)))
      (stag-pick-contents (cddr list))
    (stag-parse list)))

(defun stag-parse (sexp)
  (cond ((null sexp) nil)
        ((listp sexp)
         (let ((head (car sexp))
               (rest (cdr sexp)))
           (cond
            ((stag-tag? head)
             (stag-make-element head
                                (stag-pick-attributes rest)
                                (stag-pick-contents rest)))
            ((stringp head)
             (concat head (stag-parse rest)))
            ((null head)
             nil)
            ((listp head)
             (cons (stag-parse head) (stag-parse rest)))
            (t
             (format "%s" head)))))
        ((stag-tag? sexp)
         (stag-make-element sexp))
        (t
         (format "%s" sexp))))

(defun stag-make-element (tag &optional attribute contents)
  `((tag . ,(symbol-name tag))
    (attribute . ,attribute)
    (contents . ,contents)))

(defun stag-expand-attributes (attributes)
  (let ((str (mapconcat (lambda (attribute) (concat  (car attribute) "=\"" (cdr attribute) "\"") ) attributes " ")))
    (if (string< "" str)
        (concat " " str)
      str)))

(defun stag-element-to-html (element)
  (let ((tag (cdr (assoc 'tag element)))
        (attribute (cdr (assoc 'attribute element)))
        (contents (cdr (assoc 'contents element))))
    (if contents
        (concat "<" tag (stag-expand-attributes attribute) ">"
                (if (listp contents) "\n")
                (stag-convert-to-html contents)
                (if (listp contents) "\n")
                "</" tag ">")
      (concat "<" tag (stag-expand-attributes attribute) " />"))))

(defun stag-convert-to-html (contents)
  (cond ((stag-element? contents)
         (stag-element-to-html contents))
        ((null contents)
         "")
        ((listp contents)
         (mapconcat 'stag-convert-to-html contents "\n"))
        ((stringp contents)
         contents)
        (t
         (format "%s" contents))))

(defun stag-delete-last-sexp ()
  (let ((end (point))
        (start (progn (backward-sexp) (point))))
    (delete-region start end)))

(defun stag-smart-insert (html)
  (stag-delete-last-sexp)
  (let ((point (point)))
    (insert html)
    (indent-region point (point))))

(defun stag-convert-last-sexp ()
  (interactive)
  (stag-smart-insert
   (stag-convert-to-html
    (stag-parse
     (preceding-sexp)))))

(provide 'stag)
;;; stag.el ends here