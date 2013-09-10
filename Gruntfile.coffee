# Generated on 2013-03-26 using generator-webapp 0.1.5
"use strict"
lrSnippet = require("grunt-contrib-livereload/lib/utils").livereloadSnippet
mountFolder = (connect, dir) ->
  connect.static require("path").resolve(dir)

module.exports = (grunt) ->

  # load all grunt tasks
  require("matchdep").filterDev("grunt-*").forEach grunt.loadNpmTasks

  timestamp = grunt.template.today('mm-dd')

  # Configurable paths and globs
  buildConfig =
    timestamp: timestamp
    site:
      parent: '.site'
      target: ".site/#{timestamp}"
      subdir: timestamp
    minName: 'all-min'





  grunt.initConfig
    cfg:    buildConfig
    winter: grunt.file.readJSON 'wintersmithConfig.json'
    env:    grunt.file.readJSON '.env.json'
    pkg:    grunt.file.readJSON 'package.json'
    connect:
      options:
        port: 7042
        hostname: '0.0.0.0' #"localhost" # change this to '0.0.0.0' to access the server from outside
        site: "<%= cfg.site.parent %>"
      site:
        options:
#          keepalive: true
          middleware: (connect, options) ->
            [lrSnippet, mountFolder(connect, options.site)] #, mountFolder(connect, options.src)]

    open:
      devHome:
        path: "http://localhost:7042"

    watch:
      site:
        files: [
          'templates/*.jade'
          '<%= winter.output %>/contents/css/*.css'
        ]
        tasks: [ 'winter', 'build', 'livereload' ]

    clean:
      site:   "<%= cfg.site.parent %>"
      winter: "<%= winter.output %>"
      unusedFiles: [
        "<%= cfg.site.parent %>/css"
      ]

    concat:
      enate:
        src: 'contents/css/*.css'
        dest: "<%= cfg.site.target %>/<%= cfg.minName %>.css"

    cssmin:
      ify:
        options: report: 'min'
        files: "<%= cfg.site.target %>/<%= cfg.minName %>.css": "<%= cfg.site.target %>/<%= cfg.minName %>.css"

    replace:
      options:
        variables:
          googleAnalyticsKey:  "<%= env.googleAnalyticsKey %>"
          buildDir:            "<%= grunt.option('targetSubdir') %>"
        prefix: '@@'
      html:
        files: [
          expand: true
#          flatten: true
          cwd:  "<%= cfg.site.parent %>"
          src:  "**/*.html"
          dest: "<%= cfg.site.parent %>"
        ]

#    htmlmin: index:
#      options:
#        collapseWhitespace: true
#        removeRedundantAttributes: true
#        removeAttributeQuotes: true
#      files: "<%= grunt.option('targetParent') %>/index.html" : "<%= grunt.option('targetParent') %>/index.html"

    copy:
      rootImages: files: [
        expand: true
        src:  '*.{ico,png}'
        dest: "<%= cfg.site.parent %>"
      ]
      contentImages: files: [
        expand: true
        cwd:  'images'
        src:  '**/*.{jpg,png}'
        dest: "<%= cfg.site.target %>/images"
      ]
      blog: files: [
        expand: true
        cwd:  "<%= winter.output %>"
        src:  ['**']
        dest: "<%= cfg.site.parent %>"
      ]

    'git-describe': me: {}

    aws_s3:
      options:
        accessKeyId:     '<%= env.awsKey %>'
        secretAccessKey: '<%= env.awsSecret %>'
        bucket:          '<%= env.awsBucket %>'
        region:          '<%= env.awsRegion %>'
        concurrency: 5 # More power captain!
        params: CacheControl: 'max-age=63072000' # Two Year cache policy (60 * 60 * 24 * 730)#

      deployParent:
        options: params: CacheControl: 'max-age=120' # 2 minutes (60 * 2)
        files: [
          expand: true
          cwd: "<%= cfg.site.parent %>"
          src: '*' # all files, but only those in this immediate directory
          dest: '' # putting a slash here will cause '//path' on Amazon
        ]
      deployStatic: files: [
          expand: true
          cwd: "<%= cfg.site.target %>"
          src: [ '**' ]
          dest: "<%= cfg.site.subdir %>"
        ]

    exec: wintersmithBuild: cmd: 'wintersmith build --config wintersmithConfig.json'

  grunt.renameTask "regarde", "watch"



  # ---------------------------------------------------------------------- Task Definitions


  # wintersmith
  # -----------
  # Build the wintersmith blog and keep it in a particular folder
  grunt.registerTask 'winter', [ 'exec:wintersmithBuild' ]


  # build
  # -----
  # Clean the target dir
  # Merge separate css files into a single file
  # Move files from the source dir to a build dir
  # Copy markup files and parse them for replacements
  grunt.registerTask 'build', 'Clean the target and build to it', ->
    grunt.task.run [
      'clean:site'
      'copy'              # Move the blog files to the build destination
      'replace:html'      # Replace any build variables in html/css files
      'concat'            # merge css files together
      'cssmin'            # and make them so so tiny small
      'clean:unusedFiles' # Files that we don't actually need for distribution
    ]


  # server
  # ------
  grunt.registerTask 'server', 'Open the target folder as a web server', ->
    grunt.task.run [
      'livereload-start'
      'connect:site'
      'open'
      'watch:site'
    ]


  # deploy
  # ------
  # deploy the site to a remote location.
  grunt.registerTask 'deploy', 'Moves content from the build folder to AWS S3. Doing a build is a prereq.', ->
    grunt.task.run [
      'aws_s3:deployStatic'
      'aws_s3:deployParent'
    ]


  # ---------------------------------------------------------------------- Task Shortcuts
  grunt.registerTask "fullBuild", [ 'winter', 'build' ]
  grunt.registerTask "f", [ 'clean', 'fullBuild', 'server' ]
  grunt.registerTask "default", 'f'


  # ---------------------------------------------------------------------- Set the output path for built files.
  # Most tasks will key off this so it is a prerequisite for running any grunt task.
  setPath = (gitRevision) ->
    hash = '_' + gitRevision[0]
    grunt.option 'gitRevision', hash
    targetInfo = buildConfig.site # Default path
    targetInfo = targetPlusHash buildConfig.site, hash
    setGruntOptions targetInfo

  # Given a hash, create an object that stores dist locations
  targetPlusHash = (target, hash) ->
    targetInfo = target
    targetInfo.target += hash # Only the dist build appends the hash
    targetInfo.subdir += hash
    targetInfo

  # Given and object that specifies target locations, set global grunt variables
  setGruntOptions = (targetInfo) ->
    grunt.option 'target',       targetInfo.target
    grunt.option 'targetParent', targetInfo.parent
    grunt.option 'targetSubdir', targetInfo.subdir
    grunt.log.writeln "Output path set to: #{grunt.option 'target'}"
    grunt.log.writeln "Parent path:        #{grunt.option 'targetParent'}"
    grunt.log.writeln "Subdir:             #{grunt.option 'targetSubdir'}"

  # Run git-describe to get the revision number, and when it returns set the path for all grunt tasks
  grunt.event.once 'git-describe', setPath
  grunt.task.run 'git-describe'



