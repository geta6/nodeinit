'use strict'

coffeelint = require 'coffeelint'
{reporter} = require 'coffeelint-stylish'

module.exports = (grunt) ->

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-simple-mocha'
  grunt.loadNpmTasks 'grunt-notify'

  grunt.registerTask 'test',    [ 'coffeelint', 'coffee', 'simplemocha' ]
  grunt.registerTask 'default', [ 'test', 'watch' ]
  grunt.registerMultiTask 'coffeelint', 'CoffeeLint', ->
    count = e: 0, w: 0
    options = @options()
    (files = @filesSrc).forEach (file) ->
      grunt.verbose.writeln "Linting #{file}..."
      errors = coffeelint.lint (grunt.file.read file), options, !!/\.(litcoffee|coffee\.md)$/i.test file
      unless errors.length
        return grunt.verbose.ok()
      reporter file, errors
      errors.forEach (err) ->
        switch err.level
          when 'error' then count.e++
          when 'warn'  then count.w++
          else return
        message = "#{file}:#{err.lineNumber} #{err.message} (#{err.rule})"
        grunt.event.emit "coffeelint:#{err.level}", err.level, message
        grunt.event.emit 'coffeelint:any', err.level, message
    return no if count.e and !options.force
    if !count.w and !count.e
      grunt.log.ok "#{files.length} file#{if 1 < files.length then 's'} lint free."

  grunt.initConfig

    coffeelint:
      options:
        arrow_spacing:
          level: 'error'
        colon_assignment_spacing:
          spacing: left: 0, right: 1
          level: 'error'
        cyclomatic_complexity:
          level: 'warn'
        empty_constructor_needs_parens:
          level: 'error'
        indentation:
          level: 'error'
          value: 2
        max_line_length:
          level: 'error'
          value: 79
        newlines_after_classes:
          level: 'error'
        no_empty_functions:
          level: 'warn'
        no_empty_param_list:
          level: 'error'
        no_interpolation_in_single_quotes:
          level: 'warn'
        no_stand_alone_at:
          level: 'warn'
        no_unnecessary_double_quotes:
          level: 'warn'
        no_unnecessary_fat_arrows:
          level: 'error'
        space_operators:
          level: 'warn'
      release:
        files: [
          { expand: yes, cwd: 'src/', src: [ '**/*.coffee' ] }
          { expand: yes, cwd: 'tests/', src: [ '**/*.coffee' ] }
        ]

    coffee:
      dist:
        files: [{
          expand: yes
          cwd: 'src/'
          src: [ '**/*.coffee' ]
          dest: 'lib/'
          ext: '.js'
        }]

    simplemocha:
      options:
        ui: 'bdd'
        reporter: 'spec'
        compilers: 'coffee:coffee-script'
        ignoreLeaks: no
      dist:
        src: [ 'tests/test.coffee' ]

    watch:
      options:
        interrupt: yes
      dist:
        files: [ 'src/**/*.coffee', 'tests/**/*.coffee' ]
        tasks: [ 'test' ]

