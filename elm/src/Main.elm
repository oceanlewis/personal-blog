module Main exposing (..)

import Blog exposing (..)
import Html exposing (Html, text, div, h1, img)
import Html.Attributes exposing (src, class)
import Http exposing (getString)
import Markdown exposing (toHtml)


---- MODEL ----


type alias Model =
    { flags : Flags
    , blogModel : Blog.Model
    }


type alias Flags =
    { homeAddress : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { flags =
            { homeAddress = flags.homeAddress
            }
      , blogModel = Blog.init
      }
    , fetchBlogPosts (flags.homeAddress ++ "/api/blogs")
    )



---- UPDATE ----


type Msg
    = NoOp
    | LoadBlogPosts (Result Http.Error String)


fetchBlogPosts : String -> Cmd Msg
fetchBlogPosts url =
    Debug.log url
        url
        |> Http.getString
        |> Http.send LoadBlogPosts


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadBlogPosts result ->
            case result of
                Ok responseString ->
                    Debug.log responseString
                        ( model, Cmd.none )

                Err httpError ->
                    ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ renderBlog model.blogModel.selectedBlogId
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
