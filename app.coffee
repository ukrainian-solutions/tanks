express = require 'express'

app = express();

app.get '/', (req, res) ->
  res.send 'hello world'


app.use '/bower', express.static(__dirname + '/bower_components')
app.use '/', express.static(__dirname + '/frontend')

app.listen(3000);
