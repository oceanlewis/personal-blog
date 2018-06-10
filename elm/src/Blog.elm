module Blog exposing (..)

import Array exposing (..)


type alias Id =
    Int


type alias Title =
    String


type alias Body =
    String


type alias Post =
    { id : Id
    , title : Title
    , body : Body
    , published : Bool
    , created_at : String
    , updated_at : String
    }


type alias Model =
    { blogPosts : Array Post
    , selectedBlogId : Maybe Id
    }


init : Model
init =
    { blogPosts = Array.fromList []
    , selectedBlogId = Nothing
    }
