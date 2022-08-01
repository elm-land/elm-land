const express = require('express')
const cors = require('cors')

let app = express()
app.use(cors())
app.use(express.json())

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
        token: 'abcabc123'
      })
    } else {
      res.status(400).json({ errors })
    }
  }, 500)
})

app.listen(5000, () => {
  console.log('Backend API ready at http://localhost:5000')
})