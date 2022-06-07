<!--
SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2021–2022)
-->

# Note About Copying Information

Most projects that use both embedded [SPDX][0] info and [CC0][1] will use [SPDX
license list short identifiers][2] to identify which files are under CC0. This
project doesn’t do that. Instead, it uses [FileNotice][3] [tags][4]. Here’s
why:

[CC0 appears on the SPDX License List.][5] [The main part of the SPDX Spec
explicitly names CC0 as a license.][6] [Older versions of the Spec went even
farther in terms of calling CC0 a license.][7] Despite all of that, Creative
Commons (CC0’s creator) has said [“Please note that CC0 is not a license; it is
a public domain dedication.”][8] In one of their official decisions, the SPDX
Legal Team acknowledged that CC0 is not a license. Here are some relevant
quotes from that decision:

-------------------------------------------------------------------------------

>“‘Public Domain’ is a concept distinct from copyright licensing; it generally
>means that the work no longer has any copyright protection or ownership, and
>therefore requires no license permission in order to use, copy, modify,
>distribute, perform, display, etc.”

>“Due to the foregoing reasons, the SPDX Legal Team will continue to treat each
>unique ‘Public Domain dedication’ in the same way as any license is treated in
>the standard. We believe this is the safest, common assumption that can be
>made regarding this type of material. Some commonly used ‘Public Domain
>dedications’ have already been included in the SPDX License List (e.g., ANTLR,
>Sax, CC-0 \[sic\]), and others may be added to the List using the Process for
>Requesting New Licenses be Added.”

The full decision can be found here:
<https://wiki.spdx.org/view/Legal_Team/Decisions/Dealing_with_Public_Domain_within_SPDX_Files>.

-------------------------------------------------------------------------------

I think that this is a reasonable decision. I’m choosing to not use [SPDX
license list short identifiers][2] for CC0 because I think that it’s
misleading. In some jurisdictions, CC0 functions purely as a public domain
dedication. In others, CC0 actually does function as a license (the work
remains copyrighted!). See [CC0 Section 3][9] and [CC0 FAQ: How does it
work?][10] for details.

So, if a work says that it’s “available under the CC0 1.0 license”, what does
that mean? The author probably meant “this work is dedicated to the public
domain using CC0 1.0.” But maybe they didn’t. Maybe there was a
misunderstanding, and the author thought that the work was still copyrighted.
Maybe the author was being pedantic and meant “this work is copyrighted and is
available under CC0’s Public License Fallback license.” More importantly, what
are the legal ramifications of saying “this work is available under the CC0 1.0
license”? Legally speaking is there any difference between “available under the
CC0 1.0 license” and “dedicated to the public domain using CC0 1.0”?

Part of the reason that I use CC0 in the first place is discourage those kinds
of questions. When I decide to use CC0 on a file, I want people to just copy
the file without thinking twice about it. I understand that CC0 isn’t that
clear cut (see [public-domain][11], [Wikipedia:Granting work into the public
domain][12], and [How could using code released under CC0 infringe on the
author's patents?][13]), but it’s the best tool for the job.

## [Creative Commons’s best practices for attribution](https://wiki.creativecommons.org/wiki/Best_practices_for_attribution)

SPDX-FileAttributionText: [“Frequently Asked Questions”](https://creativecommons.org/faq/) by [Creative Commons](https://creativecommons.org/) is licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

[0]: https://spdx.dev/
[1]: https://creativecommons.org/publicdomain/zero/1.0/
[2]: https://spdx.github.io/spdx-spec/using-SPDX-short-identifiers-in-source-files/
[3]: https://spdx.github.io/spdx-spec/file-information/#813-file-notice-field
[4]: https://spdx.github.io/spdx-spec/file-tags/
[5]: https://spdx.org/licenses/CC0-1.0.html
[6]: https://spdx.github.io/spdx-spec/document-creation-information/#62-data-license-field
[7]: https://github.com/spdx/spdx-spec/issues/542
[8]: https://creativecommons.org/faq/#how-do-cc-licenses-operate
[9]: https://creativecommons.org/publicdomain/zero/1.0/legalcode
[10]: https://wiki.creativecommons.org/wiki/CC0_FAQ#How_does_it_work.3F
[11]: https://linuxmafia.com/faq/Licensing_and_Law/public-domain.html
[12]: https://en.wikipedia.org/wiki/Wikipedia:Granting_work_into_the_public_domain
[13]: https://opensource.stackexchange.com/questions/133/how-could-using-code-released-under-cc0-infringe-on-the-authors-patents
