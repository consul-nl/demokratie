(function() {
  "use strict";

  function removeWrappingParagraphs(html) {
    const tempDiv = document.createElement('div');
    tempDiv.innerHTML = html;

    // Remove <p> tags wrapping only <a> elements
    tempDiv.querySelectorAll('p').forEach(p => {
      if (p.childNodes.length === 1 && p.firstChild.tagName === 'A') {
        p.replaceWith(p.firstChild); // Replace <p> with the <a> itself
      }
    });

    return tempDiv.innerHTML;
  }

  App.HTMLEditor = {
    initialize: function() {
      var {
        ClassicEditor
      } = CKEDITOR;


      document.querySelectorAll( 'textarea.html-area' ).forEach( textarea => {
        ClassicEditor.create(textarea, {
          plugins: this.toolbarFor(textarea).plugins,
          toolbar: {
            items: this.toolbarFor(textarea).toolbarControls,
            shouldNotGroupWhenFull: true
          },

          schema: {
            allow: '$text a', // Allows `<a>` as an inline element
          },

          image: {
            toolbar: [
              'toggleImageCaption',
              'imageTextAlternative',
              '|',
              'imageStyle:inline',
              'imageStyle:wrapText',
              'imageStyle:breakText',
              '|',
              'resizeImage'
            ],
            upload: {
              types: ['jpg', 'jpeg', 'png', 'gif']
            }
          },

          heading: {
            options: [
              {
                model: 'paragraph',
                title: 'Paragraph',
                class: 'ck-heading_paragraph'
              },
              {
                model: 'heading1',
                view: 'h1',
                title: 'Heading 1',
                class: 'ck-heading_heading1'
              },
              {
                model: 'heading2',
                view: 'h2',
                title: 'Heading 2',
                class: 'ck-heading_heading2'
              },
              {
                model: 'heading3',
                view: 'h3',
                title: 'Heading 3',
                class: 'ck-heading_heading3'
              },
              {
                model: 'heading4',
                view: 'h4',
                title: 'Heading 4',
                class: 'ck-heading_heading4'
              },
              {
                model: 'heading5',
                view: 'h5',
                title: 'Heading 5',
                class: 'ck-heading_heading5'
              },
              {
                model: 'heading6',
                view: 'h6',
                title: 'Heading 6',
                class: 'ck-heading_heading6'
              }
            ]
          },

          ckfinder: {
            // Upload the images to the server using the CKFinder QuickUpload command.
            uploadUrl: 'https://example.com/ckfinder/core/connector/php/connector.php?command=QuickUpload&type=Images&responseType=json',

            // Define the CKFinder configuration (if necessary).
            options: {
              resourceType: 'Images'
            }
          },

          simpleUpload: {
            uploadUrl: '/ckeditor/pictures',
            withCredentials: true,
            headers: {
              'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
            }
          },

          htmlSupport: {
            allow: [
              {
                name: /.*/,
                attributes: true,
                classes: true,
                styles: true
              }
            ]
          },

          extraPlugins: [
            function(editor) {
              editor.sourceElement.form.addEventListener("submit", function(e) {
                e.preventDefault();

                var textarea = editor.sourceElement
                var editorData = editor.getData();
                var processedData = removeWrappingParagraphs(editorData);

                textarea.value = processedData
                textarea.form.submit();
              })

              editor.data.processor.originalToView =  editor.data.processor.toView;
              editor.data.processor.toView = (data) => {
                const viewFragment = editor.data.processor.originalToView(data);

                var domFragment = editor.data.processor.domConverter.viewToDom( viewFragment );
                var viewFragmentData =  editor.data.processor.htmlWriter.getHtml( domFragment );
                console.log({viewFragmentData})

                return viewFragment;
              };
              editor.data.processor.originalToData =  editor.data.processor.toData;
              editor.data.processor.toData = (viewFragment) => {
                var data = editor.data.processor.originalToData(viewFragment)
                data = removeWrappingParagraphs(data);
                return data
              };
            },
            function ( editor ) {
              // Allow <iframe> elements in the model.
              editor.model.schema.register( 'iframe', {
                allowWhere: '$text',
                allowContentOf: '$block'
              } );
              // Allow <iframe> elements in the model to have all attributes.
              editor.model.schema.addAttributeCheck( context => {
                if ( context.endsWith( 'iframe' ) ) {
                  return true;
                }
              } );
              // View-to-model converter converting a view <iframe> with all its attributes to the model.
              editor.conversion.for( 'upcast' ).elementToElement( {
                view: 'iframe',
                model: ( viewElement, modelWriter ) => {
                  return modelWriter.writer.createElement( 'iframe', viewElement.getAttributes() );
                }
              } );
              // Model-to-view converter for the <iframe> element (attributes are converted separately).
              editor.conversion.for( 'downcast' ).elementToElement( {
                model: 'iframe',
                view: 'iframe'
              } );
              // Model-to-view converter for <iframe> attributes.
              // Note that a lower-level, event-based API is used here.
              editor.conversion.for( 'downcast' ).add( dispatcher => {
                dispatcher.on( 'attribute', ( evt, data, conversionApi ) => {
                  // Convert <iframe> attributes only.
                  if ( data.item.name != 'iframe' ) {
                    return;
                  }
                  const viewWriter = conversionApi.writer;
                  const viewIframe = conversionApi.mapper.toViewElement( data.item );
                  // In the model-to-view conversion we convert changes.
                  // An attribute can be added or removed or changed.
                  // The below code handles all 3 cases.
                  if ( data.attributeNewValue ) {
                    viewWriter.setAttribute( data.attributeKey, data.attributeNewValue, viewIframe );
                  } else {
                    viewWriter.removeAttribute( data.attributeKey, viewIframe );
                  }
                });
              });
            },
          ],
        }).then(function(editor) {
              // editor.conversion.for('upcast').elementToElement({
              //   model: 'a',
              //   view: 'a',
              //   converterPriority: 'high'
              // });
              //
              // editor.conversion.for('downcast').elementToElement({
              //   model: 'a',
              //   view: 'a',
              //   converterPriority: 'high'
              // });
            console.log(editor.model.schema.getDefinitions())
        })
      });

      CKFinder.basePath = "http://localhost:3000/ckfinder/";

      // CKFinder.widget( 'ckfinder-widget', {
      //     configPath: '',
      //     language: 'de'
      // } );
    },

    toolbarFor: function(element) {

      var toolbarControls, plugins;
      var {
        ImageBlock,
        ImageCaption,
        ImageInline,
        ImageInsert,
        ImageInsertViaUrl,
        ImageResize,
        ImageStyle,
        ImageTextAlternative,
        ImageToolbar,
        ImageUpload,
        SimpleUploadAdapter,
        ClassicEditor,
        CKFinder,
        CKFinderUploadAdapter,
        Essentials,
        Font,
        Paragraph,
        Heading,
        List,
        Indent,
        IndentBlock,
        BlockQuote,
        Alignment,
        Link,
        Bold,
        Italic,
        Underline,
        Strikethrough,
        Subscript,
        Superscript,
        RemoveFormat,
        FontColor,
        FontBackgroundColor,
        Table,
        HorizontalLine,
        SpecialCharacters,
        SpecialCharactersEssentials,
        MediaEmbed,
        SourceEditing,
        HtmlEmbed,
        GeneralHtmlSupport,
      } = CKEDITOR;

      if ( $(element).hasClass("extended-u") ) {
        plugins = [
          Essentials, Font, Paragraph, Heading,
          List, Indent, IndentBlock, BlockQuote, Alignment,
          Link, Bold, Italic, Underline, Strikethrough, Subscript, Superscript, RemoveFormat,
          Table, HorizontalLine, SpecialCharacters, SpecialCharactersEssentials
        ]

        toolbarControls = [
          "bulletedList", "numberedList", "|", "indent", "outdent", "|", "blockQuote", "|", "alignment:left", "alignment:center", "alignment:right", "alignment:justify", "|",
          "heading", "|", "link", "|", "bold", "italic", "underline", "strikethrough", "subscript", "superscript", "|", "removeFormat", "|",
          "fontColor", "fontBackgroundColor", "|",
          "insertTable", "horizontalLine", "specialCharacters"
        ]

      } else if ( $(element).hasClass("extended-a") ) {

        plugins = [
          Essentials, Font, Paragraph, Heading,
          CKFinder, CKFinderUploadAdapter,
          List, Indent, IndentBlock, BlockQuote, Alignment,
          ImageBlock, ImageCaption, ImageInline, ImageInsert, ImageResize, ImageStyle, ImageTextAlternative, ImageToolbar, ImageUpload, SimpleUploadAdapter,
          Link, Bold, Italic, Underline, Strikethrough, Subscript, Superscript, RemoveFormat,
          Table, HorizontalLine, SpecialCharacters, SpecialCharactersEssentials,
          MediaEmbed, SourceEditing,
          HtmlEmbed, GeneralHtmlSupport
        ]

        toolbarControls = [
          "bulletedList", "numberedList", "|", "indent", "outdent", "|", "blockQuote", "|", "alignment:left", "alignment:center", "alignment:right", "alignment:justify", "|",
          "insertImage", "|",
          "ckfinder", "|",
          "heading", "|", "link", "|", "bold", "italic", "underline", "strikethrough", "subscript", "superscript", "|", "removeFormat", "|",
          "fontColor", "fontBackgroundColor", "|",
          "insertTable", "horizontalLine", "specialCharacters", "|",
          "mediaEmbed", "sourceEditing", "|",
          "htmlEmbed"
        ]

      } else {
        plugins = [Essentials,Font, Paragraph, Bold, Italic]
        toolbarControls = ["bold", "italic"]
      }

      return { plugins: plugins, toolbarControls: toolbarControls }
    }
  };
}).call(this);
