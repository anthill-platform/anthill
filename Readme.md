
<div align="center">
<img src="https://cloud.githubusercontent.com/assets/1666014/26267105/0169f088-3cf1-11e7-93e9-2d0d0169eacc.png" width="48">
</div>

# Hack In

This branch is made for the purpose of development of the anthill itself.

### Mac OS X

To setup minimal development environment on Mac Os X, you will need:

1. Install [PyCharm](https://www.jetbrains.com/pycharm/download) (Community Edition is fine)
2. Clone this branch, including all submodules

```bash
git clone -b dev https://github.com/anthill-platform/anthill.git
cd anthill
git submodule update --init --recursive
```
3. Run installation script
```bash
cd dev/osx
./setup.sh
```

It would take awhile (up to several hours). This will install Homebrew, and Homebrew will install all of the 
required components.

4. Open cloned repo in PyCharm. 

5. Setup the Project Interpreter. To do that, go to `Preferences`, select `Project Interpreter`, select `Show All` from the dropdown,
hit "+", select `Add Local`, and feed it with `/usr/local/venv/dev/bin/python`.

6. Setup the environment information

Select `dev_discovery` run configuration in PyCharm, start it, then run this:
```bash
cd dev/osx
./setup_discovery.sh
```
7. Finally, stop the previous configuration, select `all` run configuration, hit Run

<div align="center">
<img src="https://user-images.githubusercontent.com/1666014/32844921-379a61a6-ca2c-11e7-8640-3a4403a30187.png" height="24">
</div>
<br>

8. Open [http://localhost:9500](http://localhost:9500) in your browser
9. Press "Proceed", login using username `root` and password `anthill`.
10. You should see something like this:

<div align="center">
<a href="https://user-images.githubusercontent.com/1666014/32834423-3b24fef6-ca0b-11e7-8276-240d3ccb6ce8.png"><img src="https://user-images.githubusercontent.com/1666014/32834374-0ba5b288-ca0b-11e7-8f2a-0d6729f76a60.png" width="250"></a>
</div>

<br><br>
<div align="center">
Happy coding!<br>
<img src="https://user-images.githubusercontent.com/1666014/32833678-417e7866-ca08-11e7-993c-72eacab0fbee.gif">
</div>
