<%@ page import="org.languagetool.JLanguageTool; org.languagetool.Language" %>
<!doctype html>
<html><!-- see layout for attributes -->
<head>
    <script type="text/javascript" src="${resource(dir:'js/jquery', file:'jquery-1.7.1.js')}"></script>
    <script type="text/javascript" src="${resource(dir:'js/jquery-ui', file:'jquery-ui-1.10.4.min.js')}"></script>
    <link rel="stylesheet" href="${resource(dir:'css/jquery-ui/themes/smoothness', file:'jquery-ui.css')}">
    <link rel="stylesheet" href="${resource(dir:'css', file:'ruleEditor.css')}">
    <meta name="layout" content="angularRuleEditor" />
    <title><g:message code="ltc.editor.title"/></title>
    <script>
        // used in *.js as GSP doesn't get evaluated there:
        var __ruleEditorEvaluationUrl = '${resource(dir: 'ruleEditor', file: 'checkXml')}';
        var __ruleEditorTokenizeSentencesUrl = '${resource(dir: 'analysis', file: 'tokenizeSentences')}';
        var __ruleEditorSentenceAnalysisUrl = '${resource(dir: 'analysis', file: 'analyzeTextForEmbedding')}';
        var __ruleEditorPosInfoUrl = '${resource(dir: 'ruleEditor2', file: 'posTagInformation')}';
        var __ruleEditorLangCode = '${language.getShortName()}';
    </script>
    <script src="${resource(dir:'js/angular/lib', file:'angular.js')}"></script>
    <script src="${resource(dir:'js/angular/lib', file:'angular-sanitize.min.js')}"></script>
    <script src="${resource(dir:'js/angular', file:'app.js')}"></script>
    <script src="${resource(dir:'js/angular', file:'services.js')}"></script>
    <script src="${resource(dir:'js/angular', file:'directives.js')}"></script>
    <script src="${resource(dir:'js/angular/modules', file:'sortable.js')}"></script>
</head>
<body><!-- see layout for attributes -->

<div class="body ruleEditor">

  <span style="color: white;float:left">LanguageTool ${JLanguageTool.VERSION} (${JLanguageTool.BUILD_DATE})</span>

  <h1>LanguageTool Rule Editor</h1>

  <div id="introText">
      <p>LanguageTool finds errors based on rules. Each rule has a pattern
      that describes an error. A simple pattern can just be a sequence of words,
      e.g. "bed" followed by "English", which is an error as it should probably
      be "b<strong>a</strong>d English" instead. The text that is checked by 
      LanguageTool is searched for this pattern, and if it is found, the text
      at that place is considered to have an error.</p>
    
      <p style="margin-top: 8px">This page will help you to create new rules. 
      As a result, you will have your rule in XML format, which you
      can <a href="https://languagetool.org/support/" target="_blank">send to the developers</a> for inclusion in LanguageTool.
      Need help? <a target="_blank" href="https://languagetool.org/forum/">Ask in our forum.</a></p>
  </div>

  <form>

      <noscript class="warn">Please turn on Javascript.</noscript>

      <h2>Set Example Sentences</h2>
      
      <table>
          <tr>
              <td width="120"><label for="language">Language:</label></td>
              <td>
                  <select name="language" id="language" ng-model="language" ng-options="c.name for c in languages"></select>
              </td>
          </tr>

          <tr ng-repeat="exampleSentence in exampleSentences">
              <td><label ng-cloak>{{exampleSentence.type}} sentence:</label></td>
              <td>
                  <span ng-show="$index == 0">
                      <input type="text" ng-model="exampleSentence.text" placeholder="Sorry for my bed English." ng-value="exampleSentence.text"/>
                  </span>
                  <span ng-show="$index == 1">
                      <input type="text" ng-model="exampleSentence.text" placeholder="Sorry for my bad English." ng-value="exampleSentence.text"/>
                  </span>
                  <span ng-show="$index > 1">
                      <input type="text" ng-model="exampleSentence.text" ng-value="exampleSentence.text"/>
                  </span>
                  <a href ng-click="removeExampleSentence(exampleSentence)" ng-show="exampleSentences.indexOf(exampleSentence) > 1" ng-cloak>Remove</a>
                  <a href ng-click="analyzeSentence(exampleSentence)" ng-show="!exampleSentence.analysis && exampleSentence.text" ng-cloak>
                      <span ng-show="exampleSentences.indexOf(exampleSentence) > 1">&middot;</span> Show analysis</a>
                  <span ng-show="exampleSentence.analysis" ng-cloak>
                      <span ng-show="exampleSentences.indexOf(exampleSentence) > 1">&middot;</span>
                      <a href ng-click="analyzeSentence(exampleSentence)">Update analysis</a> &middot;
                      <a href ng-click="hideSentenceAnalysis(exampleSentence)">Hide analysis</a>
                  </span>
                  <div ng-show="$index == 1 && exampleSentences[0].text && exampleSentences[0].text == exampleSentences[1].text" ng-cloak>
                      <img src="${resource(dir:'images', file:'warn_sign.png')}" alt="warning sign"/> Your example sentences are identical
                  </div>
                  <div class="sentenceAnalysis" ng-show="exampleSentence.analysis" ng-bind-html="exampleSentence.analysis" ng-cloak></div>
              </td>
          </tr>

          <tr>
              <td></td>
              <td>
                  <div style="margin-top: 5px; margin-bottom: 5px" ng-show="exampleSentences[0].text && exampleSentences[1].text" ng-cloak>
                      <a href ng-click="addWrongExampleSentence()">Add another wrong example</a> &middot;
                      <a href ng-click="addCorrectedExampleSentence()">Add another correct example</a>
                  </div>
              </td>
          </tr>

          <tr>
              <td></td>
              <td>
                  <input type="submit" ng-click="createErrorPattern()" value="Create error pattern"
                         ng-disabled="!(exampleSentences[0].text && exampleSentences[1].text) || gui.patternCreationInProgress"/>
                  <img ng-show="gui.patternCreationInProgress" src="${resource(dir:'images', file:'spinner.gif')}" alt="wait symbol" ng-cloak/>
              </td>
          </tr>
      </table>


      <div ng-show="gui.patternCreated" ng-cloak>
      
          <h2>Set the Error Pattern</h2>

          <div id="patternArea">
              
              <p style="margin-bottom: 10px">Use this to specify the error pattern, i.e. the sequence of words that - if found
              in a text that is checked by LanguageTool - triggers an error message.
              <a href ng-click="addElement()">Add a token to the pattern</a> to add a word so your
              pattern gets longer and thus more specific.</p>

              <div ng-cloak ng-show="gui.knownMatchesHtml">
                  <strong>Note:</strong> LanguageTool can already detect the following error(s) in your first wrong example sentence:
                  <div ng-cloak ng-bind-html="gui.knownMatchesHtml"></div>
              </div>
              
              <label><input ng-model="caseSensitive" type="checkbox"/>&nbsp;Case-sensitive word matching</label>

              <div id="dragContainment">
                  <!-- we need this so dragging to first and last position always works properly: -->
                  <div style="padding-top:20px;padding-bottom:30px;">
                      <ul class="sortable" ui-sortable="sortableOptions" ng-model="patternElements">
                          <li ng-repeat="element in patternElements">
                              <div ng-switch on="element.tokenType">
                                  <div ng-switch-when="marker">
                                      <span class="dragHandle">&#8691; {{element.tokenValue}}</span>
                                      <a class="removeLink" href ng-click="removeElement(element)">Remove</a>
                                  </div>
                                  <div ng-switch-default>
                                      <span class="dragHandle">&#8691; Token #{{elementPosition(element)}}</span>
                                      <a class="removeLink" href ng-show="elementCount() > 1" ng-click="removeElement(element)">Remove</a>
                                      <div style="margin-left: 15px">

                                        <label><input type="radio" ng-model="element.tokenType" ng-value="TokenTypes.WORD"/>&nbsp;Word</label>
                                        <label><input type="radio" ng-model="element.tokenType" ng-value="TokenTypes.POS_TAG" />&nbsp;Part-of-speech</label>
                                        <label><input type="radio" ng-model="element.tokenType" ng-value="TokenTypes.WORD_AND_POS_TAG"/>&nbsp;Word + Part-of-speech</label>
                                        <label><input type="radio" ng-model="element.tokenType" ng-value="TokenTypes.ANY"/>&nbsp;Any word</label>
                                          
                                        <table>
                                            <tr ng-show="element.tokenType == TokenTypes.WORD || element.tokenType == TokenTypes.WORD_AND_POS_TAG">
                                                <td style="vertical-align: middle">Word:</td>
                                                <td>
                                                    <div>
                                                        <input type="text" ng-model="element.tokenValue" ng-enter="evaluateErrorPattern()"
                                                                     placeholder="word" focus-me="focusInput" />
                                                        <label title="Interpret the given word as a regular expression"><input type="checkbox" ng-model="element.regex" 
                                                               value="true" ng-disabled="element.tokenType == TokenTypes.ANY"/>&nbsp;RegExp <a href ng-click="showRegexHelp()">[?]</a></label>
                                                        <div id="regexHelp" style="display: none" title="Regular Expression Quick Help"></div>
                                                        <label title="Matches the base form (e.g. the singular for nouns) of the given word"><input type="checkbox" ng-model="element.baseform" value="false" />&nbsp;Base&nbsp;form</label>
                                                        <label title="Matches anything but the given word"><input type="checkbox" ng-model="element.negation" value="false" />&nbsp;Negate</label>
                                                        <br/>
                                                        <div ng-show="element.tokenValue.contains(' ')">
                                                            <img src="${resource(dir:'images', file:'warn_sign.png')}" alt="warning sign"/> Add another token instead of using spaces in a token
                                                        </div>
                                                        <div ng-show="looksLikeRegex(element.tokenValue) && !element.regex">
                                                            <img src="${resource(dir:'images', file:'warn_sign.png')}" alt="warning sign"/> This looks like a regular expression, but the "RegExp" checkbox is not checked
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr ng-show="element.tokenType == TokenTypes.POS_TAG || element.tokenType == TokenTypes.WORD_AND_POS_TAG">
                                                <td style="vertical-align: middle"><a ng-href="{{getPosTagUrl()}}" target="_blank">Part-of-speech:</a></td>
                                                <td>
                                                    <div>
                                                        <input type="text" ng-model="element.posTag" ng-enter="evaluateErrorPattern()"
                                                                               placeholder="part-of-speech tag" focus-me="focusInput" />
                                                        <label title="Interpret the given part-of-speech tag as a regular expression"><input type="checkbox" 
                                                               ng-model="element.posTagRegex" value="true" ng-disabled="element.tokenType == TokenTypes.ANY"/>&nbsp;RegExp <a href ng-click="showRegexHelp()">[?]</a></label>
                                                        <label title="Matches anything but the given part-of-speech tag"><input type="checkbox" ng-model="element.posTagNegation" value="false" />&nbsp;Negate</label>
                                                        <br/>
                                                        <div ng-show="looksLikeRegex(element.posTag) && !element.posTagRegex">
                                                            <img src="${resource(dir:'images', file:'warn_sign.png')}" alt="warning sign"/> This looks like a regular expression, but the "RegExp" checkbox is not checked
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                          
                                        <ul>
                                          <li ng-repeat="exception in element.exceptions">
                                              and:

                                              <a href ng-click="removeException(element, exception)" class="removeLink">Remove exception</a>

                                              <!-- copied from above, 'element' replaced with 'exception': -->

                                              <label><input type="radio" ng-model="exception.tokenType" ng-value="TokenTypes.WORD"/>&nbsp;Word</label>
                                              <label><input type="radio" ng-model="exception.tokenType" ng-value="TokenTypes.POS_TAG"/>&nbsp;Part-of-speech</label>
                                              <label><input type="radio" ng-model="exception.tokenType" ng-value="TokenTypes.WORD_AND_POS_TAG"/>&nbsp;Word + Part-of-speech</label>

                                              <table>
                                                  <tr ng-show="exception.tokenType == TokenTypes.WORD || exception.tokenType == TokenTypes.WORD_AND_POS_TAG">
                                                      <td style="vertical-align: middle">Word:</td>
                                                      <td>
                                                          <div>
                                                              <input type="text" ng-model="exception.tokenValue" ng-enter="evaluateErrorPattern()"
                                                                     placeholder="word" focus-me="focusExceptionInput" />
                                                              <label title="Interpret the given word as a regular expression"><input type="checkbox" ng-model="exception.regex" value="true" ng-disabled="exception.tokenType == TokenTypes.ANY"/>&nbsp;RegExp</label>
                                                              <label title="Matches the base form (e.g. the singular for nouns) of the given word"><input type="checkbox" ng-model="exception.baseform" value="false" />&nbsp;Base&nbsp;form</label>
                                                              <label title="Matches anything but the given word"><input type="checkbox" ng-model="exception.negation" value="false" />&nbsp;Negate</label>
                                                              <br/>
                                                              <div ng-show="exception.tokenValue.contains(' ')">
                                                                  <img src="${resource(dir:'images', file:'warn_sign.png')}" alt="warning sign"/> Add another exception instead of using spaces in a token
                                                              </div>
                                                              <div ng-show="looksLikeRegex(exception.tokenValue) && !exception.regex">
                                                                  <img src="${resource(dir:'images', file:'warn_sign.png')}" alt="warning sign"/> This looks like a regular expression, but the "RegExp" checkbox is not checked 
                                                              </div>
                                                          </div>
                                                      </td>
                                                  </tr>
                                                  <tr ng-show="exception.tokenType == TokenTypes.POS_TAG || exception.tokenType == TokenTypes.WORD_AND_POS_TAG">
                                                      <td style="vertical-align: middle"><a ng-href="{{getPosTagUrl()}}" target="_blank">Part-of-speech:</a></td>
                                                      <td>
                                                          <div>
                                                              <input type="text" ng-model="exception.posTag" ng-enter="evaluateErrorPattern()"
                                                                     placeholder="part-of-speech tag" focus-me="focusExceptionInput" />
                                                              <label title="Interpret the given part-of-speech tag as a regular expression"><input type="checkbox" ng-model="exception.posTagRegex" value="true" ng-disabled="exception.tokenType == TokenTypes.ANY"/>&nbsp;RegExp</label>
                                                              <label title="Matches anything but the given part-of-speech tag"><input type="checkbox" ng-model="exception.posTagNegation" value="false" />&nbsp;Negate</label>
                                                              <br/>
                                                              <div ng-show="looksLikeRegex(exception.posTag) && !exception.posTagRegex">
                                                                  <img src="${resource(dir:'images', file:'warn_sign.png')}" alt="warning sign"/> This looks like a regular expression, but the "RegExp" checkbox is not checked
                                                              </div>
                                                          </div>
                                                      </td>
                                                  </tr>
                                              </table>

                                          </li>
                                        </ul>
                                          
                                        <div>
                                            <a href ng-click="addException(element)" title="Add an exception for this element">Add exception</a>
                                        </div>
                                          
                                      </div>
                                  </div>
                              </div>
                          </li>
                      </ul>
                  </div>
              </div>

              &nbsp;<a href ng-click="addElement()">Add token to pattern</a>
              <span ng-show="hasNoMarker()">
              &middot;
                  <a href ng-click="addMarker()" title="The error marker specifies what part of the pattern will be underlined as incorrect">Add error marker to pattern</a>
              </span>
          </div>


          <h2>Set the Rule Details</h2>
          
          <table>
              <tr>
                  <td><label for="ruleName">Rule Name:</label></td>
                  <td><input type="text" id="ruleName" ng-model="ruleName" ng-enter="evaluateErrorPattern()" placeholder="Short rule description used for configuration"/></td>
              </tr>
              <tr>
                  <td style="width:120px"><label for="ruleMessage">Message:</label></td>
                  <td>
                      <textarea rows="3" id="ruleMessage" ng-model="ruleMessage" ng-enter="evaluateErrorPattern()"
                                placeholder="Error message shown to the user if error pattern matches"></textarea>
                      <br/>
                      <span class="metaInfo">
                        Use \1, \2 to refer to the first, second token etc. of the matched text.<br/>
                        Use 'single quotes' to mark words  that will be shown as suggestions to the user.
                      </span>
                      <ul style="margin-bottom: 15px">
                        <li ng-repeat="messageMatch in messageMatches">
                            Token Match #{{messageMatch.tokenNumber}}:
                            Case conversion: <select ng-model="messageMatch.caseConversion" ng-options="value for (key, value) in CaseConversion"></select>
                            <br/>
                            Replace RegExp <input style="width:100px" type="text" ng-model="messageMatch.regexMatch"/> with 
                                <input style="width:100px" type="text" ng-model="messageMatch.regexReplace"/>
                                <span class="metaInfo">Use $1, $2 etc to refer to (...) in the RegExp</span>
                        </li>
                      </ul>
                  </td>
              </tr>
              <tr>
                  <td><label for="shortRuleMessage">Short message:</label></td>
                  <td><input type="text" id="shortRuleMessage" ng-model="shortRuleMessage" ng-enter="evaluateErrorPattern()"
                             placeholder="A short error message shown in e.g. context menus"/>&nbsp;<span class="metaInfo">optional</span></td>
              </tr>
              <tr>
                  <td><label for="detailUrl">URL:</label></td>
                  <td>
                      <input type="text" id="detailUrl" ng-model="detailUrl" ng-enter="evaluateErrorPattern()" 
                             placeholder="URL with more information about the error"/>&nbsp;<span class="metaInfo">optional</span>
                      <div ng-show="detailUrl && !(detailUrl.startsWith('http://') || detailUrl.startsWith('https://'))">
                        <img src="${resource(dir:'images', file:'warn_sign.png')}" alt="warning sign"/> This does not seem to be a valid HTTP or HTTPS URL
                      </div>
                  </td>
              </tr>
              <tr>
                  <td></td>
                  <td>
                      <input ng-show="gui.patternCreated" type="submit" ng-click="evaluateErrorPattern()" 
                             value="Evaluate error pattern" ng-disabled="patternElements.length == 0 || !ruleMessage || !ruleName || gui.patternEvaluationInProgress">
                      <img ng-show="gui.patternEvaluationInProgress" src="${resource(dir:'images', file:'spinner.gif')}" alt="wait symbol"/>
                  </td>
              </tr>
          </table>

      </div>


      <div ng-show="gui.patternEvaluated" ng-cloak>

          <h2 ng-class="{inProgress: gui.patternEvaluationInProgress}">Check Evaluation Results</h2>

          <div id="evaluationResult" ng-class="{inProgress: gui.patternEvaluationInProgress}"></div>
          <!-- too slow: <div ng-bind-html="evaluationResult"></div>-->
          
      </div>


      <div ng-show="gui.patternEvaluated" ng-cloak>

          <h2>Copy the Resulting XML</h2>
          
          <div id="xmlIntro">
              <p>Thanks for using the online rule editor. Here's your rule in the format
              that the developers will use to integrate your rule. If you think your rule might be
              useful to other users of LanguageTool, and if all the checks under 'Evaluation Results'
              are okay, please send this rule
              <a href="https://languagetool.org/support/" target="_blank">to the LanguageTool developers</a>.</p>
              
              <p>If you just want to use it locally, add it to the <tt>grammar.xml</tt> file of your
              LanguageTool installation and restart LanguageTool.</p>
          </div>

          <pre id="ruleAsXml" ng-cloak>{{buildXml()}}</pre>

      </div>

  </form>

</div>

</body>
</html>
