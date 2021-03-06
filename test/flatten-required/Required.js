// Generated by CoffeeScript 1.6.3
(function() {
  var dir, expect, path, required;

  expect = require('chai').expect;

  path = require('path');

  required = require('../../lib/Required');

  dir = path.resolve(__dirname + '/../data');

  describe('Required', function() {
    describe('#constructor()', function() {
      it('should return an error if file is not found', function(done) {
        return required(dir + '/unknown/file.js').fail(function(err) {
          expect(err).to.be.an["instanceof"](Error);
          return done();
        }).done();
      });
      return it('should return an error if file is not a file', function(done) {
        return required(dir).fail(function(err) {
          expect(err).to.be.an["instanceof"](Error);
          return done();
        }).done();
      });
    });
    describe('#find()', function() {
      it('should return an empty result for empty file', function(done) {
        return required(dir + '/empty.js').then(function(data) {
          expect(data).to.be.eql({
            files: [],
            core: {}
          });
          return done();
        }).done();
      });
      it('should return an empty result for non-js file', function(done) {
        return required(dir + '/test.ts').then(function(data) {
          expect(data).to.be.eql({
            files: [],
            core: {}
          });
          return done();
        }).done();
      });
      it('should find dependencies in simple file', function(done) {
        return required(dir + '/simple.js').then(function(data) {
          expect(data).to.be.eql({
            files: [dir + '/a.js', dir + '/b.js', dir + '/c.js'],
            core: {}
          });
          return done();
        }).done();
      });
      it('should find dependencies in cascade', function(done) {
        return required(dir + '/cascade.js').then(function(data) {
          expect(data).to.be.eql({
            files: [dir + '/simple.js', dir + '/a.js', dir + '/b.js', dir + '/c.js'],
            core: {}
          });
          return done();
        }).done();
      });
      it('should find dependency on core module', function(done) {
        return required(dir + '/simple-core.js').then(function(data) {
          expect(data.core).to.include.keys('events');
          expect(data.core.events).not.to.be["null"];
          return done();
        }).done();
      });
      it('should find dependency for advanced core module', function(done) {
        return required(dir + '/advanced-core.js', true).then(function(data) {
          expect(data.core).to.include.keys(['fs', 'events', 'util', 'stream', 'path']);
          expect(data.core.fs).not.to.be["null"];
          expect(data.core.events).not.to.be["null"];
          expect(data.core.util).not.to.be["null"];
          expect(data.core.stream).not.to.be["null"];
          expect(data.core.path).not.to.be["null"];
          return done();
        }).done();
      });
      it('should not look for dependencies for disallowed core modules', function(done) {
        return required(dir + '/advanced-core.js', true, ['events']).then(function(data) {
          expect(data.core).to.include.keys(['fs']);
          expect(data.core.fs).to.be["null"];
          return done();
        }).done();
      });
      it('should find dependencies for allowed core modules', function(done) {
        return required(dir + '/simple-core.js', true, ['events']).then(function(data) {
          expect(data.core).to.include.keys(['events', 'domain']);
          expect(data.core.events).not.to.be["null"];
          expect(data.core.domain).to.be["null"];
          return done();
        }).done();
      });
      return it('should find first level dependencies for advanced core module ', function(done) {
        return required(dir + '/advanced-core.js', 1).then(function(data) {
          expect(data.core).to.include.keys(['fs', 'events', 'util', 'stream', 'path']);
          expect(data.core.fs).not.to.be["null"];
          expect(data.core.events).not.to.be["null"];
          expect(data.core.util).not.to.be["null"];
          expect(data.core.stream).not.to.be["null"];
          expect(data.core.path).not.to.be["null"];
          return done();
        }).done();
      });
    });
    return describe('#findMany()', function() {
      it('should return all dependencies for more files', function(done) {
        return required.findMany([dir + '/cascade.js', dir + '/simple-core.js']).then(function(data) {
          expect(data.files).to.be.eql([dir + '/simple.js', dir + '/a.js', dir + '/b.js', dir + '/c.js']);
          expect(data.core).to.include.keys('events');
          expect(data.core.events).not.to.be["null"];
          return done();
        }).done();
      });
      return it('should find only allowed core modules', function(done) {
        return required.findMany([dir + '/cascade.js', dir + '/simple-core.js', dir + '/advanced-core.js'], true, ['events']).then(function(data) {
          expect(data.core).to.include.keys(['events', 'domain', 'fs']);
          expect(data.core.events).not.to.be["null"];
          expect(data.core.domain).to.be["null"];
          expect(data.core.fs).to.be["null"];
          return done();
        }).done();
      });
    });
  });

}).call(this);
