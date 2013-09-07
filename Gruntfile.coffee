# Generated on 2013-03-26 using generator-webapp 0.1.5
"use strict"
lrSnippet = require("grunt-contrib-livereload/lib/utils").livereloadSnippet
mountFolder = (connect, dir) ->
  connect.static require("path").resolve(dir)

module.exports = (grunt) ->

  # load all grunt tasks
  require("matchdep").filterDev("grunt-*").forEach grunt.loadNpmTasks

  # Enum for target switching behavior
  TARGETS =
    dev: 'dev'
    dist:'dist'
    site:'site'

  timestamp = grunt.template.today('mm-dd')
  defaultSubdir = 'static'

  # Configurable paths and globs
  buildConfig =
    timestamp: timestamp
    src:
      parent: 'src'
      target: "src/#{defaultSubdir}"
      subdir: defaultSubdir
    dev:
      parent: '.build'
      target: ".build/#{defaultSubdir}"
      subdir: defaultSubdir
    dist:
      parent: 'dist'
      target: "dist/#{timestamp}"
      subdir: timestamp
    site:
      parent: '.site'
      target: ".site/#{timestamp}"
      subdir: timestamp
    blog:
      parent: 'blogSrc'
      target: 'blogSrc/.build'
      subdir: '.build'
    siteBucket: 'site.tidepool.co'
    research: "../OAuthProvider/public/#{timestamp}/"
    minName: 'all-min'
    libraryCSS: 'library.css'
    hbsSourceGlob: [
      "**/*.hbs"
      "!bower_components/**"
    ]
    sassSourceGlob: [
      "**/*.sass"
      "!bower_components/**"
    ]
    coffeeSourceGlob: [
      "**/*.coffee"
      "!**/*.spec.coffee"
      "!bower_components/**/*.coffee"
    ]
    jsSourceGlob: [
      '**/*.js'
      '!bower_components/**/*.js'
    ]
    jsMain: [
      'core/main.js'
    ]
    coffeeSpecGlob: '**/*.spec.coffee'
    cssSourceGlob: [
      '<%= cfg.src.parent %>/**/*.css'
      '!<%= cfg.src.target %>/bower_components/**'
      '!<%= cfg.src.parent %>/<%= cfg.libraryCSS %>'
      '!<%= cfg.src.parent %>/site.css'
    ]
    bowerComponents: 'src/static/bower_components'
    imagesGlob: [
      'images/**/{*.png,*.jpg,*.jpeg}'
      'welcome/**/{*.png,*.jpg,*.jpeg}'
      'apple*.png'
      'favicon.ico'
    ]
    specGlob: "**/*.spec.js"
    specFile: "spec.html"







  grunt.initConfig
    cfg: buildConfig
    env: grunt.file.readJSON '.env.json'
    pkg: grunt.file.readJSON 'package.json'
    connect:
      options:
        port: 7000
        hostname: '0.0.0.0' #"localhost" # change this to '0.0.0.0' to access the server from outside
        target: "<%= grunt.option('target') %>"
        src: "<%= cfg.src.parent %>"
        dev: "<%= cfg.dev.parent %>"
        dist: "<%= cfg.dist.parent %>"
        site: "<%= cfg.site.parent %>"
      dev:
        options:
          middleware: (connect, options) ->
            [lrSnippet, mountFolder(connect, options.dev), mountFolder(connect, options.src)]
      dist:
        options:
#          keepalive: true
          middleware: (connect, options) ->
            [lrSnippet, mountFolder(connect, options.dist)]
      site:
        options:
#          keepalive: true
          middleware: (connect, options) ->
            [lrSnippet, mountFolder(connect, options.site)] #, mountFolder(connect, options.src)]

    open:
      devHome:
        path: "http://assessments-front.dev/"

    watch:

      srcHtml:
        files: [ '<%= cfg.src.parent %>/*.html', '!<%= cfg.src.parent %>/<%= specFile %>.html' ]
        tasks: [ 'copy:html', 'includereplace:html' ]

      srcHbs:
        files: '<%= cfg.src.target %>/{,*}/{,*}/*.hbs'
        tasks: ['copy:hbs', 'replace:html', 'livereload']

      specHtml:
        files: '<%= cfg.src.parent %>/<%= specFile %>'
        tasks: [ 'exec:scribeSpecs', 'includereplace:html' ]

      css:
        files: '<%= cfg.cssSourceGlob %>'
        tasks: 'combineCSS'

      srcJs:
        files: [
          '<%= cfg.src.target %>/{,*}/{,*}/{,*}/*.js'
          '<%= cfg.src.target %>/{,*}/*.spec.js'
        ]
        tasks: 'livereload'

      deployedFiles:
        files: [
          "<%= grunt.option('targetParent') %>/*.html"
          "<%= grunt.option('targetParent') %>/scout.js"
          "<%= grunt.option('target') %>/<%= cfg.minName %>.css"
          "<%= grunt.option('target') %>/<%= cfg.minName %>.js"
        ]
        tasks: 'livereload'

      site:
        files: [
          '<%= cfg.src.parent %>/site.html'
          '<%= cfg.src.parent %>/site.css'
          '<%= cfg.src.parent %>/site-ie8.css'
          '<%= cfg.src.target %>/pages/app_teaser/team.html'
          '<%= cfg.src.target %>/pages/app_teaser/team.css'
          '<%= cfg.src.target %>/pages/app_teaser/app_teaser.css'
          '<%= cfg.src.target %>/pages/app_teaser/app_teaser.html'
          '<%= cfg.blog.parent %>/templates/*.jade'
          '<%= cfg.blog.parent %>/contents/css/main.css'
        ]
        tasks: [ 'winter', 'build', 'livereload' ]

    clean:
      target:       "<%= grunt.option('target') %>"
      targetParent: "<%= grunt.option('targetParent') %>"
      dev:          "<%= cfg.dev.parent %>"
      dist:         "<%= cfg.dist.parent %>"
      site:         "<%= cfg.site.parent %>"
      unoptimizedFiles: [
        "<%= grunt.option('target') %>/**/*.hbs"
        "<%= grunt.option('target') %>/**/*.js"
        "!<%= grunt.option('target') %>/<%= cfg.jsMain %>"
        "!<%= grunt.option('target') %>/bower_components/**"
      ]
      # Bower is a useful package manager, but fetches both build and dev code. We don't want to deploy that
      unusedBowerComponents: [
        # Libraries (dev only)
        "<%= grunt.option('target') %>/bower_components/{backbone-amd,bourbon,Chart.js,fastclick,jasmine,jasmine-jquery,jquery,jquery-ui,markdown,modernizr,require-handlebars-plugin,requirejs-text,sass-bootstrap,tidepool-backbone.syphon,toastr,underscore-amd}/"
        # Subfolders
        "<%= grunt.option('target') %>/bower_components/**/{fonts,docs,tests}/"
        # File Types
        "<%= grunt.option('target') %>/bower_components/**/*.{html,jpg,png,md,doc,map,gemspec,lock,rb,ico,markdown,yml,json}"
      ]

    coffee:
      options:
        bare: true
        sourceMap: true
      cup:
        files: [
          expand: true
          cwd:  '<%= cfg.src.parent %>'
          src:  '<%= cfg.coffeeSourceGlob %>'
          dest: '<%= cfg.src.parent %>' # Create compiled files as siblings of source files
          ext:  '.js'
        ]
      spec:
        options: sourceMap: false
        files: [
          expand: true
          cwd:  '<%= cfg.src.target %>'
          src:  '<%= cfg.coffeeSpecGlob %>'
          dest: '<%= cfg.src.target %>'
          ext:  '.spec.js'
        ]

    sass:
      quatch:
        options: style: 'compact'
        files: [
          expand: true
          cwd:  '<%= cfg.src.parent %>'
          src:  '<%= cfg.sassSourceGlob %>'
          dest: '<%= cfg.src.parent %>' # Create css files as siblings of sass files
          ext:  '.css'
        ]

    concat:
      enate:
        src: '<%= cfg.cssSourceGlob %>'
        dest: "<%= grunt.option('target') %>/<%= cfg.minName %>.css"

    cssmin:
      ify:
        options: report: 'min'
        files: "<%= grunt.option('target') %>/<%= cfg.minName %>.css": "<%= grunt.option('target') %>/<%= cfg.minName %>.css"


    # https://github.com/jrburke/r.js/blob/master/build/example.build.js
    requirejs:
      oneForAll:
        options:
          baseUrl: "<%= grunt.option('target') %>"
          mainConfigFile: "<%= cfg.src.parent %>/_require_config.js"
          skipDirOptimize: true # don't optimize non AMD files in the dir
          name: 'core'
          include: [
#            'pages/dashboard/mood'
#            'pages/dashboard/personality'
#            'pages/dashboard/productivity'
#            'pages/dashboard/summary'
#            'pages/about'
#            'pages/demographics'
            'pages/error'
            'pages/friend_survey'
            'pages/game_results'
            'pages/home'
            'pages/play_game'
            'pages/social_results'
          ]
          paths:
            jquery: 'empty:' #http://requirejs.org/docs/optimization.html#empty
            bootstrap: 'empty:'
          out: '<%= grunt.option("target") %>/core/main.js'
          optimize: "uglify2"
#          optimize: "none"
          generateSourceMaps: true
          preserveLicenseComments: false
#          removeCombined: true # Does not accurately identify all files it has combined. Using a manual clean instead
          skipPragmas: true # we don't use them, and they may slow the build

    replace:
      options:
        variables:
          apiServer:           "<%= env.apiServer %>"
          appSecret:           "<%= env.appSecret %>"
          appId:               "<%= env.appId %>"
          kissKey:             "<%= env.kissKey %>"
          googleAnalyticsKey:  "<%= env.googleAnalyticsKey %>"
          fbId:                "<%= env.fbId %>"
          #fbSecret:            "<%= env.fbSecret %>" # not used
          isDev:               "<%= env.isDev %>"
          timestamp:           "<%= cfg.timestamp %>"
          buildDir:            "<%= grunt.option('targetSubdir') %>"
        prefix: '@@'
      config:
        files: [
          expand: true
          flatten: true
          src: '<%= cfg.src.target %>/core/config.js'
          dest: "<%= grunt.option('target') %>/core/"
        ]
      html:
        files: [
          expand: true
#          flatten: true
          cwd: "<%= grunt.option('targetParent') %>"
          src: "{*.html,**/*.hbs}"
          dest: "<%= grunt.option('targetParent') %>"
        ]


    includereplace:
      options:
        includesDir: '<%= cfg.src.parent %>'
        globals:
          buildDir: "<%= grunt.option('targetSubdir') %>"
      html: files: [
        expand: true
        cwd: "<%= grunt.option('targetParent') %>"
        src: '*.html'
        dest: "<%= grunt.option('targetParent') %>"
      ]
      marketingSite: files: [
        expand: true
        cwd: "<%= cfg.src.parent %>"
        src: 'site.html'
        dest: "<%= cfg.site.parent %>"
      ]

    uglify: requirejs: files: "<%= cfg.src.target %>/bower_components/requirejs/require.min.js" : "<%= cfg.src.target %>/bower_components/requirejs/require.js"

    htmlmin: index:
      options:
        collapseWhitespace: true
        removeRedundantAttributes: true
        removeAttributeQuotes: true
      files: "<%= grunt.option('targetParent') %>/index.html" : "<%= grunt.option('targetParent') %>/index.html"


    copy:
      bower: files: [
          expand: true
          cwd:  "<%= cfg.src.target %>/bower_components"
          src:  '**/*.*'
          dest: "<%= grunt.option('target') %>/bower_components"
        ]
      hbs: files: [
          expand: true
          cwd:  "<%= cfg.src.target %>"
          src:  "<%= cfg.hbsSourceGlob %>"
          dest: "<%= grunt.option('target') %>"
        ]
      html: files: [
          expand: true
          cwd:  "<%= cfg.src.parent %>"
          src:  '{index.html,library.html,404.html,redirect.html,additional_redirect.html}'
          dest: "<%= grunt.option('targetParent') %>"
        ]
      js: files: [
          expand: true
          cwd:  "<%= cfg.src.target %>"
          src:  "<%= cfg.jsSourceGlob %>"
          dest: "<%= grunt.option('target') %>"
        ]
      assetImages: files: [
          expand: true
          cwd:  "<%= cfg.src.target %>"
          src:  "<%= cfg.imagesGlob %>"
          dest: "<%= grunt.option('target') %>"
        ]
      rootImages: files: [
          expand: true
          cwd:  "<%= cfg.src.parent %>"
          src:  "<%= cfg.imagesGlob %>"
          dest: "<%= grunt.option('targetParent') %>"
        ]
      siteAssetImages: files: [
        expand: true
        cwd:  "<%= cfg.src.target %>"
        src:  [
          'images/app_teaser/*.{jpg,png}'
          'images/people/*.{jpg,png}'
          'images/tidepool.png'
          'images/home_page/homepage*.jpg'
          'images/home_page/phone_bg*.jpg'
        ]
        dest: "<%= grunt.option('target') %>"
      ]
      blog: files: [
        expand: true
        cwd:  "<%= cfg.blog.target %>"
        src:  '**'
        dest: "<%= grunt.option('targetParent') %>/blog/"
      ]

    'git-describe': me: {}

    pngmin:
      options:
        ext: '.png'
        force: true
      root: files: [
          expand: true
          cwd:  "<%= grunt.option('targetParent') %>"
          src:  '*.png'
          dest: "<%= grunt.option('targetParent') %>"
        ]
      target: files: [
          expand: true
          cwd:  "<%= grunt.option('target') %>"
          src:  ['welcome/**/*.png', 'images/**/*.png']
          dest: "<%= grunt.option('target') %>"
        ]

    compress:
      options: pretty: true
      mainPackages:
        expand: true
        cwd: "<%= grunt.option('target') %>"
        src: '**/{<%= cfg.minName %>.css,core/main.js}'
        dest: "<%= grunt.option('target') %>"

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
          cwd: "<%= grunt.option('targetParent') %>"
          src: '*' # all files, but only those in this immediate directory
          dest: '' # putting a slash here will cause '//path' on Amazon
        ]
      deployStatic: files: [
          expand: true
          cwd: "<%= grunt.option('target') %>"
          src: [ '**', '!**/*.gz' ]
          dest: "<%= grunt.option('targetSubdir') %>"
        ]
      deployGzipped:
        options: params:
          ContentEncoding: 'gzip'
          CacheControl: 'max-age=120' # 2 minutes (60 * 2)
        files: [
          { # The Minified CSS file
            expand: true
            cwd: "<%= grunt.option('target') %>"
            src: "<%= cfg.minName %>.css.gz"
            dest: "<%= grunt.option('targetSubdir') %>"
            ext: '.css'
            params: ContentType: 'text/css'
          }
          { # The Javascript package
            expand: true
            cwd: "<%= grunt.option('target') %>"
            src: "core/main.js.gz"
            dest: "<%= grunt.option('targetSubdir') %>"
            ext: '.js'
            params: ContentType: 'application/javascript'
          }
        ]
      siteParent:
        options:
          bucket: "<%= cfg.siteBucket %>"
          params: CacheControl: 'max-age=120' # 2 minutes (60 * 2)
        files: [
          expand: true
          cwd: "<%= grunt.option('targetParent') %>"
          src: '*' # all files, but only those in this immediate directory
          dest: '' # putting a slash here will cause '//path' on Amazon
        ]
      siteStatic:
        options: bucket: "<%= cfg.siteBucket %>"
        files: [
          expand: true
          cwd: "<%= grunt.option('target') %>"
          src: [ '**', '!**/*.gz' ]
          dest: "<%= grunt.option('targetSubdir') %>"
        ]

    exec:
      jqueryuiAmd:  cmd: "jqueryui-amd <%= cfg.src.target %>/bower_components/jquery-ui"
      unitTest:     cmd: "node_modules/phantomjs/bin/phantomjs resources/run.js http://localhost:<%= connect.options.port %>/<%= cfg.specFile %>"
      scribeSpecs:  cmd: 'ruby resources/scribeAmdDependencies.rb "<%= grunt.option(\"targetParent\") %>/" "<%= cfg.src.parent %>/" "<%= cfg.src.target %>/" "<%= cfg.specGlob %>" "<%= cfg.specFile %>" bower_components'
      cleanEmpties: cmd: "find <%= grunt.option('target') %> -type d -empty -delete"
      renameSite:   cmd: "mv <%= cfg.site.parent %>/site.html <%= cfg.site.parent %>/index.html"
      wintersmithB: cmd: 'wintersmith build --chdir <%= cfg.blog.parent %>'

  grunt.renameTask "regarde", "watch"



  # ---------------------------------------------------------------------- Task Definitions

  # precompile
  # ----------
  # Turn SASS into CSS as sibling files
  # Turn Coffeescript into JS as sibling files
  # Optional to run if you preocompile SASS and Coffeescript on your dev machine
  grunt.registerTask 'precompile', ->
    grunt.task.run [ 'sass', 'coffee' ]


  # wintersmith
  # -----------
  # Build the wintersmith blog and keep it in a particular folder
  grunt.registerTask 'winter', ->
    grunt.task.run [
      'exec:wintersmithB'              # Generate the wintersmith blog site
      ]


  # combineCSS
  # ----------
  grunt.registerTask 'combineCSS', 'Combines css into one file. With minify if the --dist option is set.', ->
    grunt.task.run 'concat'
    grunt.task.run('cssmin') if grunt.option TARGETS.dist # only minify non-dist builds


  # build
  # -----
  # Clean the target dir
  # Merge separate css files into a single file
  # Move files from the source dir to a build dir
  # Copy markup files and parse them for replacements
  grunt.registerTask 'build', 'Clean the target and build to it', ->
    if grunt.option TARGETS.site
      grunt.log.writeln "Building in Site Mode"
      grunt.task.run [
        'clean:targetParent'             # clean out the target dir
        'copy:blog'                      # Move the blog files to the build destination
        'includereplace:marketingSite'   # Include files into the main html file and replace variables
        'exec:renameSite'                # Rename site.html to index.html
        'htmlmin:index:removeComments'
        'copy:rootImages'
        'copy:siteAssetImages'
      ]
    else
      grunt.task.run [
        "exec:jqueryuiAmd"
        'uglify:requirejs'    # RequireJS doesn't have a min version, this puts one in the bower folder for it
        'clean:targetParent'  # clean out the target dir
        'combineCSS'          # Merge css into a single file and put that file in the target timestamp dir
        'copy:bower'          # Copy bower dependencies to the target timestamp dir
        'copy:html'           # Move all html to the target parent dir
        'copy:hbs'            # Copy all hbs templates to the target dir. Necessary so that we can replace @@buildDir for image references
        'exec:scribeSpecs'    # find all .spec.js files and write them into spec.html
        'includereplace:html' # include files and parse variables
        'replace:html'        # parse build variables in html files
        'replace:config'      # replace build values
        'htmlmin'
      ]
      if grunt.option TARGETS.dist
        grunt.log.writeln "Building in Dist Mode"
        grunt.task.run [
          'clean:targetParent'  # clean out the target dir
          'copy:js'
          'requirejs'
          'clean:unoptimizedFiles'
          'clean:unusedBowerComponents'
          'copy:rootImages'
          'copy:assetImages'
          'exec:cleanEmpties'
          'compress'
        ]
      else
        grunt.log.writeln "Building in Dev Mode"


  # server
  # ------
  grunt.registerTask 'server', 'Open the target folder as a web server', ->
    if grunt.option TARGETS.site
      grunt.task.run [
        'livereload-start'
        'connect:site'
        'open'
        'watch:site'
      ]
    if grunt.option TARGETS.dist
      grunt.task.run [
        'livereload-start'
        'open'
        'connect:dist:keepalive'
      ]
    else
      grunt.task.run [
        'livereload-start'
        'connect:dev'
        'open'
        'watch'
      ]


  # test
  # ----
  grunt.registerTask 'test', 'Start a server and run unit tests. build task is a prereq', [ 'connect:dev', 'exec:unitTest' ]


  # deploy
  # ------
  # deploy the site to a remote location. Only valid for --dist and --site builds so far
  grunt.registerTask 'deploy', 'Moves content from the dist folder to AWS S3. Dist build is a prereq.', ->
#    targetInfo = getDistTargetWithHash grunt.option 'gitRevision'
#    setGruntOptions targetInfo
    if grunt.option TARGETS.site
      grunt.log.writeln "Deploying standalone/marketing site"
      grunt.task.run [
        'build'
        'aws_s3:siteStatic'
        'aws_s3:siteParent'
      ]
    else if grunt.option TARGETS.dist
      grunt.log.writeln "Deploying dist"
      grunt.task.run [
        'aws_s3:deployStatic'
        'aws_s3:deployParent'
        'aws_s3:deployGzipped'
      ]
    else
      grunt.fail.warn 'No action taken -- can only deploy to dist or site target'


  # ---------------------------------------------------------------------- Task Shortcuts
  grunt.registerTask 'pre', 'precompile'
  grunt.registerTask "b", [ 'build' ] # because of zsh's stupid 'build' autocorrect message
  grunt.registerTask "s", [ 'clean', 'build', 'server' ]
  grunt.registerTask 'spec', 'exec:unitTest'
  grunt.registerTask "default", 's'


  # ---------------------------------------------------------------------- Set the output path for built files.
  # Most tasks will key off this so it is a prerequisite for running any grunt task.
  setPath = (gitRevision) ->
    hash = '_' + gitRevision[0]
    grunt.option 'gitRevision', hash
    targetInfo = buildConfig.dev # Default path
    if grunt.option TARGETS.dist
      targetInfo = targetPlusHash buildConfig.dist, hash
    else if grunt.option TARGETS.site
      targetInfo = targetPlusHash buildConfig.site, hash
    else
      grunt.option TARGETS.dev, true
      targetInfo = buildConfig.dev
    setGruntOptions targetInfo
    targets = []
    targets.push target for target of TARGETS
    grunt.log.writeln "You can set targets using grunt options, such as `--dev`"
    grunt.log.writeln "Possible targets for this project: #{targets.join(', ')}"

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



