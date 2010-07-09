stag.el --- Writing HTML with S-expression
==========================================

Install
-------

    (require 'stag)
    (define-key sgml-mode-map (kbd "C-c C-e") 'stag-convert-last-sexp)

Summary
-------

    <html>
      <head>
        <title>Writing HTML with S-expression</title>
      </head>
      <body>
        (div :id "main"
           (h1 "Stag")
           (ul :class "navi"
             (li (a :href "/menu1" "menu 1"))
             (li (a :href "/menu1" "menu 2"))
             (li (a :href "/menu1" "menu 3"))))_
      </body>
    </html>

press `C-c C-e` at `_`

    <html>
      <head>
        <title>Writing HTML with S-expression</title>
      </head>
      <body>
        <div id="main">
          <h1>Stag</h1>
          <ul class="navi">
            <li>
              <a href="/menu1">menu 1</a>
            </li>
            <li>
              <a href="/menu1">menu 2</a>
            </li>
            <li>
              <a href="/menu1">menu 3</a>
            </li>
          </ul>
        </div>_
      </body>
    </html>
