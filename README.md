# vltk-jenkins-cookbook

TODO: Enter the cookbook description here.

## Supported Platforms

TODO: List your supported platforms.

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['vltk-jenkins']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

### vltk-jenkins::default

Include `vltk-jenkins` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[vltk-jenkins::default]"
  ]
}
```

## License and Authors

Author:: private, inc. (<vlad.tkatchev@gmail.com>)
