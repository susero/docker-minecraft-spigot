# はじめに

このコンテナは日本人管理者の利用を前提としたspigotサーバーです。
サーバーのLOCALEは日本に設定してあります。

最初にコンテナを起動した時にSpigotのインストーラーがダウンロードされ、ビルドが行われます。

# dockerイメージのビルド

```sh
mkdir -p spigot/data/assets
cd spigot
git clone susero/docker-minecraft-spigot .
docker build -t susero/minecraft-server-spigot .
```

# dockerコンテナの起動

```sh
docker run --rm -e "AGREE_TO_EULA=true" -v $(pwd)/data:/home/spigot/data -p 25565:25565 susero/minecraft-server-spigot
```

初めて起動した時は、Spigotのインストーラーが自動的にダウンロードされ、Spigotのビルド(コンパイル）が行われます。
このプロセスは米国デジタルミレニアム著作権法上の問題を回避するために行われるものです。２度目の起動からは、ビルド済みのプログラムが使用されます。
ビルドと最初の起動には、Core2Duo U9400 1.40GHzで、約30分かかりました。気長にお待ちください。



# コンテナの設定項目

AGREE_TO_EULA(=false)

    Minecraftサーバーを使用するにはMOJANGとの契約に同意しなければなりません。
    Trueを明示的に指定する必要があります。

JVM_XMS(=512M)
JVM_XMX(=1400M)

    JAVA仮想マシンが利用可能なメモリ量を指定します。
    Bukkit/Spigotの場合、JVM_XMXは2GBが推奨されているようです。
    安価なクラウドや、古めのマシンだとマシン本体のメモリが2GB程度のものが多いと思われるので、デフォルトは少なめに指定してあります。

JVM_XXMPS(=128M)

    JVMにXXMaxPermSizeを指定します。
    Spigotのフォーラムでは、Minecraftのバージョンが1.7以降の場合、128Mに指定することが推奨されているようなので、デフォルト値として128Mを指定してあります。
    ワールド数が多くなったりすると、より多くのメモリを割り当てる必要があるかもしれません。

USERMAP_UID(none)

    ホスト上でデータを管理するアカウントのUIDを指定します。

