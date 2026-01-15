#
//  ci_post_clone.sh
//  DotLife
//
//  Created by An Tran on 15/1/26.
//

#!/bin/sh
brew install --formula tuist@4.104.6

tuist generate
