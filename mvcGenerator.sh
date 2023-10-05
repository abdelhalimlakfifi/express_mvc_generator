#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage: $0 <project_name> [--api]"
  exit 1
fi

project_name=$1
is_api=false

if [ $# -eq 2 ] && [ "$2" == "--api" ]; then
  is_api=true
fi

mkdir $project_name
cd $project_name
npm init -y
npm install express mongoose

if [ "$is_api" = false ]; then
  mkdir -p public/css public/js views
fi

mkdir -p models controllers
touch app.js

if [ "$is_api" = false ]; then
  touch views/index.ejs
fi

touch models/sampleModel.js
touch controllers/sampleController.js

if [ "$is_api" = false ]; then
  mkdir -p public/css public/js
fi

if [ "$is_api" = true ]; then
  echo "VIEW_ENGINE=none" > .env
else
  echo "VIEW_ENGINE=ejs" > .env
fi

cat <<EOL >> app.js
const express = require('express');
const mongoose = require('mongoose');

const app = express();

const viewEngine = process.env.VIEW_ENGINE || 'ejs';
if (viewEngine !== 'none') {
  const ejs = require('ejs');
  app.set('view engine', viewEngine);
  app.set('views', __dirname + '/views');
}

mongoose.connect('mongodb://localhost/${project_name}', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  useCreateIndex: true,
  useFindAndModify: false
});

const db = mongoose.connection;
db.on('error', console.error.bind(console, 'MongoDB connection error:'));

const sampleRouter = require('./controllers/sampleController');
app.use('/sample', sampleRouter);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log('Server is running on port ' + PORT);
});
EOL

cat <<EOL >> controllers/sampleController.js
const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
  res.status(200).json({ message: 'Welcome to the ${project_name}' });
});

module.exports = router;
EOL

if [ "$is_api" = false ]; then
  cat <<EOL >> views/index.ejs
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Welcome to ${project_name}</title>
</head>
<body>
  <h1>Welcome to ${project_name}</h1>
</body>
</html>
EOL
fi

git init
echo "node_modules/" >> .gitignore
git add .
git commit -m "Initial commit"

echo "Express.js project '${project_name}' created successfully."
if [ "$is_api" = true ]; then
  echo "This is an API project."
else
  echo "To get started, run 'cd ${project_name}' and then 'npm start'."
fi
