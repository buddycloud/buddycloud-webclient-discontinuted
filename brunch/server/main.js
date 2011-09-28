var util = require('util');
var path = require('path');
var port = 3000;

var express = require("express");
var app = express.createServer();

var buildPath = path.join(__dirname, '..', 'build');


app.configure(function(){
    app.set('views', buildPath);
    app.use(express.static(buildPath));
});

var index_html = require('fs').readFileSync(path.join(buildPath, "index.html"));

var index = function(req, res){
  res.header('Content-Type', 'text/html');
  res.end(index_html);
};

app.get('/',            index);
app.get('/welcome',     index);
app.get('/more',        index);
app.get('/login',       index);
app.get('/register',    index);
app.get('/:id@:domain', index);


util.log("starting server on port " + port);
app.listen(parseInt(port, 10));
