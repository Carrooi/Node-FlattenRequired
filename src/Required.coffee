fs = require 'fs'
Q = require 'q'
path = require 'path'
required = require 'required'
Module = require 'module'

class Required


	file: null

	coreDepth: false

	files: null

	core: null

	processed: null


	constructor: (@file) ->
		@files = []
		@core = {}
		@processed = []

		if !fs.existsSync(@file)
			throw new Error 'File ' + @file + ' does not exist.'

		if !fs.statSync(@file).isFile()
			throw new Error 'Path ' + @file + ' must be file.'


	@findMany: (files, coreDepth = false) ->
		result = []
		for file in files
			r = new Required(file)
			r.coreDepth = coreDepth
			result.push(r.find())

		deferred = Q.defer()
		Q.all(result).then( (data) ->
			result =
				files: []
				core: {}

			for deps in data
				result.files = result.files.concat(deps.files)
				result.core = Required.mergeObjects(result.core, deps.core)

			result.files = Required.removeDuplicates(result.files)

			deferred.resolve(result)
		).fail( (err) ->
			deferred.reject(err)
		)
		return deferred.promise


	find: (file = @file, depth = 1) ->
		if path.extname(file) != '.js'
			@processed.push(file)
			return Q.resolve(
				files: @files
				core: @core
			)

		deferred = Q.defer()
		required(file, ignoreMissing: true, (e, deps) =>
			@processed.push(file)

			if e
				deferred.reject(e)
			else
				for dep in deps
					@parse(dep)

				@finish(depth).then( (result) ->
					deferred.resolve(result)
				).fail( (err) ->
					deferred.reject(err)
				)
		)
		return deferred.promise


	parse: (dep) ->
		if dep.core == true
			@core[dep.id] = null if typeof @core[dep.id] == 'undefined'
		else
			if @files.indexOf(dep.filename) == -1
				@files.push(dep.filename)
				for sub in dep.deps
					@parse(sub)


	finish: (depth = 1) ->
		deferred = Q.defer()

		cores = []
		for module, p of @core
			@core[module] = @findCorePath(module)
			if @core[module] != null && @processed.indexOf(@core[module]) == -1 && @coreDepth != false && (@coreDepth == true || (depth <= @coreDepth))
				cores.push(@find(@core[module], depth + 1))

		Q.all(cores).then( =>
			deferred.resolve(
				files: @files
				core: @core
			)
		).fail( (err) ->
			deferred.reject(err)
		)

		return deferred.promise


	findCorePath: (name) ->
		for dir in Module.globalPaths
			file = "#{dir}/#{name}.js"
			if fs.existsSync(file) && fs.statSync(file).isFile()
				return file

		return null


	@removeDuplicates: (array) ->
		return array.filter( (el, pos) -> return array.indexOf(el) == pos)


	@mergeObjects: (first, second) ->
		for key, value of second
			first[key] = value

		return first


fn = (file, coreDepth = false) ->
	try
		r = new Required(file)
	catch e
		return Q.reject(e)

	r.coreDepth = coreDepth
	return r.find()

fn.findMany = (files, coreDepth = false) ->
	try
		return Required.findMany(files, coreDepth)
	catch e
		return Q.reject(e)


module.exports = fn