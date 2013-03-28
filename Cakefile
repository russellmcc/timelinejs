child = require 'child_process'

task 'package', 'package up before committing', ->
  child.exec 'docket timeline.coffee -m', ->
    child.exec 'docket lib/* examples/* -d doc_html', ->
      child.exec 'coffee -c timeline.coffee', ->
        child.exec 'uglifyjs timeline.js -o timeline.min.js'