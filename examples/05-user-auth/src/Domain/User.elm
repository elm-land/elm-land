module Domain.User exposing (User)


type alias User =
    { id : Int
    , name : String
    , profileImageUrl : String
    , email : String
    }
