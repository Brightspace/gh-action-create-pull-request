# gh-action-create-pull-request
Creates a PR with any changes made during a GitHub Action

## Example Usage

```
name: Push local changes
on:
  workflow-dispatch
jobs:
  make-changes:
    name: Make some changes
    runs-on: ubuntu-latest

    steps:
      - uses: Brightspace/third-party-actions@actions/checkout
      # Make some local changes to your repo using some other GitHub action here
      - uses: Brightspace/gh-action-create-pull-request@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          commit-message-prefix: fix          # defaults 'chore'
          git-user-email: myemail@example.com # defaults to '41898282+github-actions[bot]@users.noreply.github.com'
          git-user-name: Test                 # defaults to 'github-actions[bot]'
          pull-request-labels: test
```
