const express = require('express')
const cors = require('cors')

const SECRET_TOKEN_EXAMPLE = 'ryans-secret-token'

let app = express()
app.use(cors())
app.use(express.json())

// This endpoint returns a token
app.use('/api/sign-in', (req, res) => {
  let errors = []
  console.log(req.body)

  // 1. Check for missing email field
  if (!req.body.email) {
    errors.push({
      field: 'email',
      message: 'Email is required.'
    })
  }

  // 2. Check for missing password
  if (!req.body.password) {
    errors.push({
      field: 'password',
      message: 'Password is required.'
    })
  }

  // 3. After a delay, send a response
  setTimeout(() => {
    if (errors.length === 0) {
      res.status(200).json({
        token: SECRET_TOKEN_EXAMPLE
      })
    } else {
      res.status(400).json({ errors })
    }
  }, 500)
})

// This endpoint returns a User, but needs a token!
app.get('/api/me', (req, res) => {
  if (req.query.token === SECRET_TOKEN_EXAMPLE) {
    res.status(200).json({
      id: 1,
      name: 'Ryan Haskell-Glatz',
      profileImageUrl: 'https://avatars.githubusercontent.com/u/6187256?v=4',
      email: 'ryan@elm.land'
    })
  } else {
    res.status(401).json({
      message: 'Token is required to access /api/me'
    })
  }
})

app.listen(5000, () => {
  console.log('Backend API ready at http://localhost:5000')
})