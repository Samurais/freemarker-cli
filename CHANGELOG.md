# Change Log

All notable changes to this project will be documented in this file. We try to adhere to https://github.com/olivierlacan/keep-a-changelog.

## 2.0.0-BETA-4-SNAPSHOT 

## 2.0.0-BETA-3-SNAPSHOT - 2019-10-20

### Added
- Keeping track of internally created "Closables" of a document and closing them after rendering
- Define CSV delimiters using symbolic symbolic names, e.g. "COMMA", "TAB", etc.

### Fixed
- Use expected order of FreeMarker MultiTemplateLoader to reolve a template

## 2.0.0-BETA-2 - 2019-10-15

### Added
- Add "-E" command line option to expose all environment variable as top-level entry in the data model 
- Support for [Grok](https://github.com/thekrakken/java-grok) as better alternative for regular expressions
- Support for streaming textual content over `System.in` to allow processing of arbitrary large source files
- Display Git version information when using `-V` command line option

### Fixed
- ExcelTool uses MissingCellPolicy.CREATE_NULL_AS_BLANK to handle missing cells
- Pass the correct output encoding to writer
- Allow absolute template file names which are loaded directly instead of using TemplateLoaders

## [2.0.0-BETA-1] - 2019-10-12

### Added
- Support for YAML files using SnakeYAML

### Changed
- Upgraded dependencies
- Migrated from Groovy to plain old JDK 1.8
- Works as standalone application with OS wrapper scripts
- Existing templates will break due to naming changes of injected helper classes

[2.0.0-BETA-1]: https://github.com/sgoeschl/freemarker-cli/releases/tag/v2.0.0-BETA-1
