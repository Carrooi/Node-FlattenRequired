expect = require('chai').expect
path = require 'path'

required = require '../../lib/Required'

dir = path.resolve(__dirname + '/../data')

describe 'Required', ->

	describe '#constructor()', ->
		it 'should return an error if file is not found', (done) ->
			required(dir + '/unknown/file.js').fail( (err) ->
				expect(err).to.be.an.instanceof(Error)
				done()
			).done()

		it 'should return an error if file is not a file', (done) ->
			required(dir).fail( (err) ->
				expect(err).to.be.an.instanceof(Error)
				done()
			).done()

	describe '#find()', ->
		it 'should return an empty result for empty file', (done) ->
			required(dir + '/empty.js').then( (data) ->
				expect(data).to.be.eql(
					files: []
					core: {}
				)
				done()
			).done()

		it 'should return an empty result for non-js file', (done) ->
			required(dir + '/test.ts').then( (data) ->
				expect(data).to.be.eql(
					files: []
					core: {}
				)
				done()
			).done()

		it 'should find dependencies in simple file', (done) ->
			required(dir + '/simple.js').then( (data) ->
				expect(data).to.be.eql(
					files: [
						dir + '/a.js'
						dir + '/b.js'
						dir + '/c.js'
					]
					core: {}
				)
				done()
			).done()

		it 'should find dependencies in cascade', (done) ->
			required(dir + '/cascade.js').then( (data) ->
				expect(data).to.be.eql(
					files: [
						dir + '/simple.js'
						dir + '/a.js'
						dir + '/b.js'
						dir + '/c.js'
					]
					core: {}
				)
				done()
			).done()

		it 'should find dependency on core module', (done) ->
			required(dir + '/simple-core.js').then( (data) ->
				expect(data.core).to.include.keys('events')
				expect(data.core.events).not.to.be.null
				done()
			).done()

		it 'should find dependency for advanced core module', (done) ->
			required(dir + '/advanced-core.js', true).then( (data) ->
				expect(data.core).to.include.keys(['fs', 'events', 'util', 'stream', 'path'])		# and many other
				expect(data.core.fs).not.to.be.null
				expect(data.core.events).not.to.be.null
				expect(data.core.util).not.to.be.null
				expect(data.core.stream).not.to.be.null
				expect(data.core.path).not.to.be.null
				done()
			).done()

		it 'should not look for dependencies for disallowed core modules', (done) ->
			required(dir + '/advanced-core.js', true, ['events']).then( (data) ->
				expect(data.core).to.include.keys(['fs'])
				expect(data.core.fs).to.be.null
				done()
			).done()

		it 'should find dependencies for allowed core modules', (done) ->
			required(dir + '/simple-core.js', true, ['events']).then( (data) ->
				expect(data.core).to.include.keys(['events', 'domain'])
				expect(data.core.events).not.to.be.null
				expect(data.core.domain).to.be.null
				done()
			).done()

		it 'should find first level dependencies for advanced core module ', (done) ->
			required(dir + '/advanced-core.js', 1).then( (data) ->
				expect(data.core).to.include.keys(['fs', 'events', 'util', 'stream', 'path'])		# and many other
				expect(data.core.fs).not.to.be.null
				expect(data.core.events).not.to.be.null
				expect(data.core.util).not.to.be.null
				expect(data.core.stream).not.to.be.null
				expect(data.core.path).not.to.be.null
				done()
			).done()

	describe '#findMany()', ->
		it 'should return all dependencies for more files', (done) ->
			required.findMany([
				dir + '/cascade.js'
				dir + '/simple-core.js'
			]).then( (data) ->
				expect(data.files).to.be.eql([
					dir + '/simple.js'
					dir + '/a.js'
					dir + '/b.js'
					dir + '/c.js'
				])
				expect(data.core).to.include.keys('events')
				expect(data.core.events).not.to.be.null
				done()
			).done()

		it 'should find only allowed core modules', (done) ->
			required.findMany([
				dir + '/cascade.js'
				dir + '/simple-core.js'
				dir + '/advanced-core.js'
			], true, ['events']).then( (data) ->
				expect(data.core).to.include.keys(['events', 'domain', 'fs'])
				expect(data.core.events).not.to.be.null
				expect(data.core.domain).to.be.null
				expect(data.core.fs).to.be.null
				done()
			).done()