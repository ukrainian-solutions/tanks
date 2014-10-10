gulp = require 'gulp'
coffee = require 'gulp-coffee'
sourcemaps = require 'gulp-sourcemaps'
cached = require 'gulp-cached'
concat = require 'gulp-concat'

requirejs = require 'requirejs'
runSequence = require 'run-sequence'


#Public used

gulp.task 'default', ->
  runSequence '_dev', 'watch'

#Private
gulp.task '_dev', ['coffee']

gulp.task 'coffee', ->
  gulp.src(['./frontend_src/**/*.coffee', './frontend_src/*.coffee'])
  .pipe(sourcemaps.init())
  .pipe(cached('coffee'))
    .pipe(coffee(bare: true).on('error', handleError))
  .pipe(sourcemaps.write())
  .pipe(gulp.dest('./frontend'))

gulp.task 'watch', ->
  gulp.watch ['./frontend_src/**/*.coffee', './frontend_src/*.coffee'], ['coffee']


handleError = (err) ->
  console.log err.toString()
  @emit 'end'