module Main exposing (..)

import Blog exposing (..)
import Html exposing (Html, text, div, h1, img)
import Html.Attributes exposing (src, class)
import Http exposing (getString)
import Array exposing (..)
import Html.Events exposing (on)


---- MODEL ----


type alias Model =
    { flags : Flags
    , blog : Blog.Model
    }


type alias Flags =
    { homeAddress : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { flags =
            { homeAddress = flags.homeAddress
            }
      , blog = Blog.init
      }
    , fetchBlogPosts (flags.homeAddress ++ "/api/blogs")
    )



---- UPDATE ----


type Msg
    = NoOp
    | LoadBlogPosts (Result Http.Error String)
    | SelectBlogPost Int


fetchBlogPosts : String -> Cmd Msg
fetchBlogPosts url =
    url
        |> Http.getString
        |> Http.send LoadBlogPosts


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadBlogPosts result ->
            case result of
                Ok responseString ->
                    let
                        blogPostArray =
                            decodePostsFrom responseString
                    in
                        case blogPostArray of
                            Ok posts ->
                                ( { model
                                    | blog = (updateBlogPosts model.blog posts)
                                  }
                                , Cmd.none
                                )

                            Err e ->
                                ( model, Cmd.none )

                Err httpError ->
                    ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

        SelectBlogPost id ->
            ( { model
                | blog = updateSelectedPost model.blog id
              }
            , Cmd.none
            )



---- VIEW ----


blogPostSelectOption : Blog.Post -> Html Msg
blogPostSelectOption post =
    Html.option [ Html.Attributes.value (toString post.id) ] [ text post.title ]


blogPostSelect : Blog.Model -> Html Msg
blogPostSelect blog =
    Html.select
        [{--Invoke onChange here. --}
        ]
        (blog.posts
            |> Array.toList
            |> List.map blogPostSelectOption
        )


view : Model -> Html Msg
view model =
    div []
        [ blogPostSelect model.blog
        , blogContent model.blog
        ]


blogContent : Blog.Model -> Html Msg
blogContent blogModel =
    case blogModel.selectedId of
        Just blogId ->
            renderBlog blogModel.posts blogId

        Nothing ->
            renderEmptyBlog



{--
            div []
                [ div [ class "blog-title" ] [ text "Hi" ]
                , Markdown.toHtml [ class "blog-body" ] """

# This is my first blog post!

  ### I'm sure I'll have lots of incredibly great stuff to say....

  1. Invent the universe.
  2. Bake an apple pie.

"""
                ]
--}
---- PROGRAM ----


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
