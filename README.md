# flatten-required

Flatten required module with list of all core dependencies.

Uses [q](https://npmjs.org/package/q) promise library.

## Installation

```
$ npm install flatten-required
```

## Usage

Result is just simple object without any depth (like original [required](https://npmjs.org/package/required) library).

```
var required = require('flatten-required');

required('/path/to/my/file.js').then(function(result) {
	// do something with results
});
```

### Result object

* `files`: list of paths to all required files (recursively)
* `core`: object with list of used core modules

### Load all core dependencies

If you want to get all dependencies (even from all core files recursively) you have to set depth of nesting.

There we load all used modules recursively (quite slow):

```
required('/path/to/module/with/core/module.js', true).then(function(result) {
	// do something
});
```

Another options is to set final depth of nesting:

```
required('/path/to/module/with/core/module.js', 2).then(function(result) {
	// do something
});
```

## Find dependencies for more files

```
required.findMany([
	'/first/file.js',
	'/second/file.js'
]).then(function(result) {
	// do something
});
```

This will load all dependencies from these two files and merge their results. You can of course use also depth for core modules.

## Tests

```
$ npm test
```

## Changelog

* 1.0.0
	+ Initial version