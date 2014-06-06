{$, $$$, ScrollView} = require 'atom'

module.exports =
class AskStackResultView extends ScrollView
  @content: ->
    @div class: 'ask-stack-result native-key-bindings', tabindex: -1

  initialize: ->
      super

  destroy: ->
    @unsubscribe()

  getTitle: ->
    "Ask Stack Results"

  getUri: ->
    "ask-stack://result-view"

  handleEvents: ->
    @subscribe this, 'core:move-up', => @scrollUp()
    @subscribe this, 'core:move-down', => @scrollDown()

  renderAnswers: (answersJson) ->
    # Do stuff
    test = '''
<div class="ui-result">

	<h2 class="title">
		<a class="underline" href="javascript:void(0);">
			<span class="title-string">"Implements Runnable" vs. "extends Thread"</span>
		</a>
		<div class="score"><p> 488 </p></div>
	</h2>
	<div class="tags">
	    <span class="label label-info"><a href="#/tag/java">java</a></span>
	    <span class="label label-info"><a href="#/tag/multithreading">multithreading</a></span>
	</div>
	<div class="created">
		February 12th 2009, 6:28:46 am
	</div>
<p>From what time I've spent with threads in Java, I've found these two ways to write threads.</p>
<button type="button" class="btn btn-default btn-xs">Copy</button>
<button type="button" class="btn btn-default btn-xs">Insert</button>
<pre><code>public class ThreadA implements Runnable {
    public void run() {
        //Code
    }
}
//with a "new Thread(threadA).start()" call


public class ThreadB extends Thread {
    public ThreadB() {
        super("ThreadB");
    }
    public void run() {
        //Code
    }
}
//with a "threadB.start()" call
</code>
                    </pre>
</div>
    '''
    @html(test + test)
