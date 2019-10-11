# AutoConfigShellScript
Automatically compile and configure ffmpeg, Python 3.7.2(default), PyAV, OpenCV, Keras, Tensorflow(CPU Mode) and other relative environment.

--- 

<h3 id="ProjectEnv">Project Env</h3>

* System: CentOS (7.4 & 7.5); Other Version is waiting for test.

---

<h3 id="ProjectInfo">Project Info</h3>

* Filename:    auto_config.sh
* Revision:    1.2
* Date:        2019/09/05
* UpdateTime:  2019/10/11
* Author:      sunhailin-Leo
* Email:       379978424@qq.com
* Website:     https://github.com/sunhailin-Leo
* License：    **Use Mulan PSL v1.**

---

<h3 id="ChangeLog">Change Log</h3>

* Version 1.2
    * Fix a fatal error with install python and public dependency
    * Add a new command about help doc (--h or -help)
    * Test at CentOS 7.4 & 7.5 can use this shell script.
* Version 1.1
    * Fix a fatal error with environment config.
    * Use ~/.bashrc instead of ~/.bash_profile in docker image.
* Version 1.0
    * Finish shell script test and run.
