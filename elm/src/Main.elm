module Main exposing (..)

import Html exposing (Html, text, div, h1, img)
import Html.Attributes exposing (src, class)
import Http exposing (getString)
import Markdown exposing (toHtml)


---- MODEL ----


type alias Model =
    { flags : Flags
    }


type alias Flags =
    { homeAddress : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { flags =
            { homeAddress = flags.homeAddress }
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


blogPath : Model -> String -> String
blogPath model name =
    model.flags.homeAddress ++ "/" ++ name


fetchBlogPost : String -> Http.Request String
fetchBlogPost path =
    Http.getString path


view : Model -> Html Msg
view model =
    div []
        [ renderBlog (blogPath model "test.md")
        ]


renderBlog : String -> Html msg
renderBlog path =
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
