# Zwip

A simple HTTP file server. Supports easy grouping of file downloads and zip streaming.

## Features

- HTTP file listing.
- File download selection via a cart system.
- 2 download options:
  - Streamed zip download, to avoid buffering.
  - Multi-link download, automatically start 1 download/per file (though folders are still zipped).

## Demo

A demo is running over there: https://zwip.herokuapp.com/

## Requirements

* [Crystal](https://crystal-lang.org/) 0.28.0
* zip(1) (Crystal does not suport Zip64 yet)

## Running

```Shell
$ git clone https://github.com/martin-leydier/Zwip.git
$ cd zwip
$ make shards
$ make run
```
