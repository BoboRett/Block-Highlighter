{CompositeDisposable} = require 'atom'

module.exports = FoldLines =
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    self = this
    @subscriptions.add atom.workspace.observeTextEditors ( editor ) =>
      foldsLayer = editor.displayLayer.foldsMarkerLayer

      fn = ->
        [document.querySelectorAll( "[fold-child='true']" )...].forEach( (a) => a.setAttribute( "fold-child", false ))
        for cursor in editor.cursors
          self.highlightBlock self.srch( cursor, editor, false), self.srch( cursor, editor, true)
        return

      @subscriptions.add editor.onDidChangeCursorPosition fn
      @subscriptions.add editor.onDidAddCursor fn
      @subscriptions.add editor.component.element.onDidChangeScrollTop fn


  deactivate: ->
    @subscriptions.dispose()

  highlightBlock: ( i, end ) ->
    while i < end
      document.querySelector("[data-buffer-row='" + i + "']") && document.querySelector("[data-buffer-row='" + i + "']").setAttribute( "fold-child", true );
      i++;

  srch: ( cursor, editor, forward) ->
    srchPos = cursor.getBufferPosition().row
    while editor.lineTextForBufferRow(srchPos) == ''
      srchPos = srchPos - 1
    indent = editor.indentationForBufferRow(srchPos)

    while ( if srchPos >= 0 && srchPos < editor.getLastBufferRow() then editor.indentationForBufferRow(srchPos) >= indent else false )
      srchPos = srchPos + if forward then 1 else - 1
      while editor.lineTextForBufferRow(srchPos) == ''
        srchPos = srchPos + if forward then 1 else - 1

    srchPos
