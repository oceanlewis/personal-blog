module Blog exposing (..)

import Array exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class)
import Markdown exposing (toHtml)
import Json.Decode exposing (array, int, string, float, nullable, bool, Decoder)
import Json.Decode.Pipeline exposing (decode, required, optional)


---- Model ----


type alias Post =
    { id : Int
    , title : String
    , body : String
    , published : Bool
    , created_at : String
    , updated_at : String
    }


type alias Posts =
    Array Post


type alias Model =
    { posts : Array Post
    , selectedId : Maybe Int
    }


init : Model
init =
    { posts = Array.fromList []
    , selectedId = Nothing
    }


updateBlogPosts : Model -> Array Post -> Model
updateBlogPosts model newPosts =
    { model
        | posts = newPosts
    }


updateSelectedPost : Model -> Int -> Model
updateSelectedPost model id =
    { model
        | selectedId = Just id
    }


renderBlog : Array Post -> Int -> Html msg
renderBlog blogs id =
    case (Array.get id blogs) of
        Nothing ->
            div [] []

        Just blog ->
            div []
                [ h2 [ class "blog-title" ] [ text blog.title ]
                , Markdown.toHtml [ class "blog-body" ] blog.body
                ]


renderEmptyBlog : Html msg
renderEmptyBlog =
    div []
        [ h2 [ class "blog-title" ] [ text "No Blog Selected" ]
        , div [ class "blog-body" ] [ text "No Blog Selected" ]
        ]


postDecoder : Decoder Post
postDecoder =
    decode Post
        |> required "id" int
        |> required "title" string
        |> required "body" string
        |> required "published" bool
        |> required "created_at" string
        |> required "updated_at" string


postsDecoder : Decoder (Array Post)
postsDecoder =
    array postDecoder


decodePostsFrom : String -> Result String (Array Post)
decodePostsFrom decodable =
    Json.Decode.decodeString postsDecoder decodable
