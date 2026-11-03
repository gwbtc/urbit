{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    tools = {
      flake = false;
      url = "github:urbit/tools/d454e2482c3d4820d37db6d5625a6d40db975864";
    };
  };

  outputs = { self, nixpkgs, flake-utils, tools }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        usableTools = pkgs.runCommand "patched-tools" { } ''
          cp -r ${tools} $out
          chmod +w -R $out
          patchShebangs $out
        '';
        pkgs = import nixpkgs { inherit system; };
        click = usableTools + "/pkg/click/click";
        bootFakeShip = { pill, arvo }:
          pkgs.runCommand "fake-pier" { } ''
            ${./urbit} --pier $out -F zod -B ${pill} -l -x -t -A ${arvo}
          '';
        #  boot the stock pill as is; a kernel upgrade from it to this
        #  repo's arvo would need state migrations we don't have
        #
        builderPier = pkgs.runCommand "builder-pier" { } ''
          ${./urbit} --pier $out -F zod -B ${./bin/brass.pill} -l -x -t
        '';
        mountSourceThread = pkgs.writeTextFile {
          name = "mount-source.hoon";
          text = ''
            =/  m  (strand ,vase)
            ;<  [=ship =desk =case]  bind:m  get-beak
            ;<  now=@da  bind:m  get-time
            ;<  ~  bind:m
              (send-raw-card %pass /merg %arvo %c %merg %source ship %base da+now %init)
            ;<  [=wire =sign-arvo]  bind:m  take-sign-arvo
            ?>  ?=([%clay %mere %& *] sign-arvo)
            ;<  ~  bind:m
              (send-raw-card %pass /mont %arvo %c %mont %source [ship %source da+now] /)
            (pure:m !>(~))
          '';
        };
        buildSourcePillThread = pkgs.writeTextFile {
          name = "build-source-pill.hoon";
          text = ''
            =/  m  (strand ,vase)
            ;<  [=ship =desk =case]  bind:m  get-beak
            ;<  ~  bind:m  (send-raw-card %pass /dirk %arvo %c %dirk %source)
            ;<  =riot:clay  bind:m  (warp ship %source ~ %sing %w ud+2 /)
            ;<  ~  bind:m  (poke [ship %dojo] %lens-command !>([%$ [%dojo '+pill/brass %source'] [%output-pill 'brass/pill']]))
            ;<  ~  bind:m  (poke [ship %hood] %drum-exit !>(~))
            (pure:m !>(~))
          '';
        };
        #  build a brass pill from this repo's arvo on the builder ship
        #
        sourcePill = pkgs.runCommand "source-brass.pill" { buildInputs = [ pkgs.netcat ]; } ''
          cp -r ${builderPier} pier
          chmod +w -R pier
          ${./urbit} -d pier
          ${click} -k -p -i ${mountSourceThread} pier
          for i in $(seq 1 60); do
            [ -f pier/source/sys/arvo.hoon ] && break
            sleep 1
          done
          rm -rf pier/source/sys
          cp -rL ${./pkg}/arvo/. pier/source/
          chmod +w -R pier/source
          ${click} -k -p -i ${buildSourcePillThread} pier

          # Sleep to let urbit spin down properly
          sleep 5

          cp pier/.urb/put/brass.pill $out
        '';
        fakePier = bootFakeShip {
          pill = sourcePill;
          arvo = "${./pkg}/arvo";
        };
        testPier = bootFakeShip {
          pill = sourcePill;
          arvo = pkgs.runCommand "test-arvo" {} ''
            cp -r ${./pkg} $out
            chmod +w -R $out
            cp -r ${./tests} $out/arvo/tests
            cp -r ${./test-desk.bill} $out/arvo/desk.bill
          '' + "/arvo";
        };
        buildPillThread = pill:
          pkgs.writeTextFile {
            name = "";
            text = ''
              =/  m  (strand ,vase)
              ;<  [=ship =desk =case]  bind:m  get-beak
              ;<  ~  bind:m  (poke [ship %dojo] %lens-command !>([%$ [%dojo '+${pill}'] [%output-pill '${pill}/pill']]))
              ;<  ~  bind:m  (poke [ship %hood] %drum-exit !>(~))
              (pure:m !>(~))
            '';
          };
        buildPill = pill:
          pkgs.runCommand ("${pill}.pill") { buildInputs = [ pkgs.netcat ]; } ''
            cp -r ${fakePier} pier
            chmod +w -R pier
            ${./urbit} -d pier
            ${click} -k -p -i ${buildPillThread pill} pier

            # Sleep to let urbit spin down properly
            sleep 5

            cp pier/.urb/put/${pill}.pill $out
          '';

      in {
        checks = {
          testFakeShip = import ./nix/test-fake-ship.nix {
            inherit pkgs;
            pier = testPier;
            inherit click;
          };
        };
        packages = {
          inherit builderPier sourcePill fakePier testPier;
          brass = buildPill "brass";
          ivory = buildPill "ivory";
          solid = buildPill "solid";
        };
      });
}
