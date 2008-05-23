package org.languagetool

import javax.mail.*
import javax.mail.internet.*
import de.danielnaber.languagetool.*

class CorpusMatchController extends BaseController {
    
    public final static int NEGATIVE_OPINION = 0
    public final static int POSITIVE_OPINION = 1
    
    def beforeInterceptor = [action: this.&auth, except: ['list', 'index']]

    def allowedMethods = [markUseful:'POST', markUseless:'POST']

    def index = {
      redirect(action:list,params:params)
    }

    def list = {
      if(!params.max) params.max = 10
      String langCode = "en"
      if (params.lang) {
          langCode = params.lang
      }
      [ corpusMatchList: CorpusMatch.findAllByLanguageCode(langCode, params),
        languages: Language.REAL_LANGUAGES ]
    }

    def markUseful = {
      saveOpinion(session.user, POSITIVE_OPINION)
      render "[message marked as useful]"
    }

    def markUseless = {
      saveOpinion(session.user, NEGATIVE_OPINION)
      render "[message marked as useless]"
    }

    private void saveOpinion(User user, int opinionValue) {
      // TODO: avoid duplicate opinions
      CorpusMatch corpusMatch = CorpusMatch.get(params.id)
      assert(corpusMatch)
      UserOpinion opinion = new UserOpinion(session.user, corpusMatch, opinionValue)
      if (!opinion.save()) {
        throw new Exception("Could not save user opinion: ${opinion.errors}")
      }
    }

}