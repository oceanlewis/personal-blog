module Main exposing (..)

import Blog exposing (..)
import Array exposing (..)
import Html exposing (Html, text, div, h1, img)
import Html.Attributes exposing (src, class)
import Http exposing (getString)
import Markdown exposing (toHtml)


---- MODEL ----


type alias Model =
    { flags : Flags
    , blogPosts : Array Blog.Post
    , selectedBlogId : Maybe Blog.Id
    }


type alias Flags =
    { homeAddress : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { flags =
            { homeAddress = flags.homeAddress
            }
      , blogPosts = Array.fromList []
      , selectedBlogId = Nothing
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



---- VIEW ----
{--
blogPath : Model -> String -> String
blogPath model name =
    model.flags.homeAddress ++ "/" ++ name


fetchBlogPost : String -> Http.Request String
fetchBlogPost path =
    Http.getString path
--}


view : Model -> Html Msg
view model =
    div []
        [ renderBlog model.selectedBlogId
        ]


renderBlog : Maybe Blog.Id -> Html msg
renderBlog blogId =
    case blogId of
        Nothing ->
            div []
                [ text "No Blog Selected"
                ]

        Just blogId ->
            div []
                -- [ Markdown.toHtml [ class "blog-content" ] path ]
                [ Markdown.toHtml [ class "blog-content" ] """

# This is my first blog post!

  ### I'm sure I'll have lots of incredibly great stuff to say....

  1. Invent the universe.
  2. Bake an apple pie.

"""
                ]



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
