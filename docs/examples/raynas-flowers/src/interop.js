import _ from 'lodash'

export const flags = ({ env }) => {
  console.log({ env })
  console.log(_.add(1, 2))
}