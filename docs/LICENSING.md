# Licensing and Attribution Notes

## Why this file exists

The supplied archive contains multiple upstream components and robot/scene assets. Licensing should therefore be checked component-by-component before publishing a public derivative repository.

## Observations from the supplied archive

- The bundled `pymoveit2/LICENSE` is a BSD license.
- `panda_vision/package.xml` declares MIT.
- `panda_bringup/package.xml` declares Apache 2.0.
- Several other package manifests still contain `TODO: License declaration`.
- The supplied upstream README says the overall project is MIT, but the uploaded archive does not contain a root `LICENSE` file.

## Upstream attribution

The source archive corresponds to the public `MechaMind-Labs/Franka_Panda_Color_Sorting_Robot` repository. Preserve the original project attribution when redistributing or publishing a derivative work.

## Recommendation before making the repository public

1. Keep the upstream attribution in `README.md`.
2. Keep `pymoveit2/LICENSE` unchanged.
3. Verify the licensing of the Panda meshes and bundled Gazebo assets.
4. Do not add a new root MIT/Apache license until the licensing of all bundled components has been verified.
5. If you substantially modify the project, clearly describe which parts are your modifications.
