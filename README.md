# tedslittlerobot/homebrew-tap

Homebrew formulae for tedslittlerobot's tools.

| Formula | What it is |
|---------|------------|
| [`semvu`](Formula/semvu.rb) | [semvu](https://github.com/tedslittlerobot/semvu) (Semantic Version Utilities): modify semantic versions and find the latest one in git tags |

## Installing

```sh
brew install tedslittlerobot/tap/semvu
```

Or tap once, then use the short name:

```sh
brew tap tedslittlerobot/tap
brew install semvu
```

In a `Brewfile`:

```ruby
tap "tedslittlerobot/tap"
brew "semvu"
```

Upgrade with `brew upgrade semvu`. Shell completions for bash, zsh and fish
are installed with it.

Formulae build from source, so where there's no bottle (a prebuilt binary) for
your platform, Homebrew installs Go to build it. Bottles are built for Apple
Silicon macOS and for Linux on x86-64.

## How a release reaches Homebrew

The formula builds from each release's source tarball, so nothing in the
semvu repository pushes here. Instead:

1. A `v*.*.*` tag on [semvu](https://github.com/tedslittlerobot/semvu)
   publishes a GitHub release. Pre-releases (release candidates) are skipped:
   the formula's `livecheck` follows GitHub's *latest* release.
2. **brew bump** (`.github/workflows/autobump.yml`) runs daily, sees the new
   version and opens a pull request that updates the formula's `url` and
   `sha256`. To pick a release up straight away, run the workflow by hand
   from the Actions tab.
3. **brew test-bot** (`tests.yml`) runs on that pull request: it audits the
   formula, builds it, runs its `test do` block and builds bottles.
4. When it passes, run the **brew pr-pull** workflow (`publish.yml`) from the
   Actions tab with the pull request number. It uploads the bottles to a
   release in this repository, commits the formula with its `bottle do`
   block to `main` and closes the pull request.

Step 4 is the only manual one per release.

## One-time setup

**`HOMEBREW_TAP_TOKEN` secret.** GitHub doesn't run workflows for pull
requests opened with a workflow's own `GITHUB_TOKEN`, so without this the
bump pull request in step 2 gets no tests or bottles. Create a
[fine-grained personal access token](https://github.com/settings/personal-access-tokens/new)
with access to **this repository only**, with these permissions:

- Contents: read and write
- Pull requests: read and write

Add it under *Settings → Secrets and variables → Actions* as
`HOMEBREW_TAP_TOKEN`. Without it, autobump still works: close and reopen its
pull request to start the tests.

**Actions permissions.** Under *Settings → Actions → General*, allow
*Read and write permissions* for workflows, so **brew pr-pull** can push to
`main` and create the bottle release.

## Working on a formula

```sh
brew tap tedslittlerobot/tap
cd "$(brew --repository tedslittlerobot/tap)"
brew install --build-from-source semvu
brew test semvu
brew audit --strict --online semvu
brew style tedslittlerobot/tap
```

Change a formula through a pull request, so test-bot checks it and builds new
bottles. A change that doesn't bump the version but changes what's built
needs `revision 1` (and so on) to rebuild the bottles.

The workflows come from `brew tap-new`. To compare them with the current
template, run `brew tap-new --no-git scratch/compare` and diff its `.github`
folder against this one (`brew untap scratch/compare` afterwards).
