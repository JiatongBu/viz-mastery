# 第二章：数据可视化工具
## 2.1 Python可视化

### 2.1.1 Matplotlib基础
Matplotlib是Python最基础的可视化库，提供了极高的自由度和完整的控制能力。科研可视化来说，我们无需用到过于复杂的代码逻辑，因此本节仅关注较为基础的功能。

**安装与基本使用**

Matplotlib的安装非常简单，可以通过以下命令安装：

```python
pip install matplotlib
```

在安装完成后，导入Matplotlib的标准库 pyplot，它包含了创建图形的常用功能
```python
import matplotlib.pyplot as plt
```

首先创建一个简单的折线图
```python
import matplotlib.pyplot as plt

x = [0, 1, 2, 3, 4]
y = [0, 1, 4, 9, 16]

# 绘制折线图
plt.plot(x, y)
plt.show()
```

在此基础之上，我们可以设置标题和标签

```python
plt.plot(x, y)
plt.title('Sample Plot') # plt.title() 设置标题
plt.xlabel('X Axis')
plt.ylabel('Y Axis') # plt.xlabel() 和 plt.ylabel() 设置坐标轴标签
plt.show()
```
同时，我们可以定制坐标轴
```python
plt.plot(x, y)
plt.xlim(0, 5)  # 设置 X 轴范围
plt.ylim(0, 20)  # 设置 Y 轴范围
plt.show()
```
可以自定义图形的外观，诸如线条、颜色和样式等
```python
plt.plot(x, y, linestyle='--', color='r', linewidth=2)
plt.show()

# linestyle='--' 改变线型为虚线

# color='r' 设置线条颜色为红色

# linewidth=2 设置线条宽度


```
也可以在背景当中添加网格线
```python
plt.plot(x, y)
plt.grid(True)
plt.show()
```
好的，现在我们以细胞密度随小时的变化图像为例，把我们提到的功能都加上
```python
import matplotlib.pyplot as plt
import numpy as np

# 示例数据：时间（小时）和细胞密度（细胞数/毫升）
time = np.array([0, 2, 4, 6, 8, 10])  # 时间点
cell_density = np.array([1.5, 3.0, 5.2, 8.0, 12.1, 15.0])  # 细胞密度
error = np.array([0.1, 0.2, 0.2, 0.3, 0.4, 0.5])  # 测量误差

# 创建图形
plt.plot(time, cell_density, marker='o', color='green', linestyle='-', linewidth=2, markersize=8)

# 设置标题和标签
plt.title('Cell Density Over Time', fontsize=14, fontweight='bold')
plt.xlabel('Time (hours)', fontsize=12)
plt.ylabel('Cell Density (cells/mL)', fontsize=12)

# 设置坐标轴范围
plt.xlim(0, 10)
plt.ylim(0, 16)


# 显示网格线
plt.grid(True, which='both', linestyle='--', linewidth=0.5, alpha=0.7)

# 显示图形
plt.show()


```

从美学方面来看，这个图表还不够好。直接拿Python输出的图片用于印刷可能会比较勉强，下一节我们会提到更加规范的科研制图技巧。


### 2.1.2 学术风格的应用
对于科研论文的绘图来说，制图不仅仅是，还有很多规范需要考虑到。我们列举一些比较常用的注意事项。

我们仍然以之前的数据为例：

**网格的使用**


为了简洁与美观，期刊里倾向于使用轻微的网格线，或选择性使用、甚至不使用网格线，以避免分散注意力。过于显眼或密集的网格线可能会让图形显得杂乱。

我们可以将网格线设置为更淡的辅助线。


```python
plt.grid(True, which='major', linestyle='-', linewidth=0.5, color='gray', alpha=0.3)
```

**误差条的设计**

如果存在误差条或者其他设计，其本身通常不显眼，线条宽度更细，端点更小，以减少视觉干扰。同时，也建议将数据点标记的样式调整得更突出，以便于读者聚焦数据本身。

```python
plt.errorbar(time, cell_density, yerr=error, fmt='o', capsize=3, elinewidth=0.8, color='black', markersize=6, markerfacecolor='white')
```





**配色的修改**


关于配色，之前已经提到过，在这里我们可以采用更加柔和的色彩搭配，同事同时减少彩虹色等过于鲜艳的配色。
在统一单一主色，我们可以并结合灰度和透明度来区分次要元素（如误差条和网格线）。

```python
plt.plot(time, cell_density, marker='o', linestyle='-', color='darkblue', linewidth=2, markersize=8)
```

让我们看看修改过的成品吧


```python
import matplotlib.pyplot as plt
import numpy as np

# 示例数据
time = np.array([0, 2, 4, 6, 8, 10])  # 时间点
cell_density = np.array([1.5, 3.0, 5.2, 8.0, 12.1, 15.0])  # 细胞密度
error = np.array([0.1, 0.2, 0.2, 0.3, 0.4, 0.5])  # 测量误差

# 创建图形，调整尺寸
plt.figure(figsize=(6, 4))

# 绘制主线条和误差条
plt.plot(time, cell_density, marker='o', linestyle='-', color='#1f77b4', linewidth=2, markersize=8, label='Cell Density')
plt.errorbar(time, cell_density, yerr=error, fmt='o', capsize=3, elinewidth=1.0, color='#ff7f0e', markersize=6, label='Measurement Error')

# 添加标注，向上偏移0.6个单位
for i, txt in enumerate(cell_density):
    plt.text(time[i], cell_density[i] + 0.6, f'{txt:.1f}', fontsize=8, ha='center', color='#1f77b4')

# 设置标题和坐标轴标签，字体为 Times New Roman
plt.title('Cell Density Over Time', fontsize=14, fontweight='bold', family='Times New Roman')
plt.xlabel('Time (hours)', fontsize=12, family='Times New Roman')
plt.ylabel('Cell Density (cells/mL)', fontsize=12, family='Times New Roman')

# 调整坐标轴范围和网格
plt.xlim(-1, 11)
plt.ylim(0, 16.5)
plt.grid(True, which='major', linestyle='--', linewidth=0.5, color='gray', alpha=0.3)

# 添加图例，使用专业配色对应
plt.legend(loc='upper left', fontsize=10, frameon=False)

# 自动调整布局
plt.tight_layout()

# 导出图形为 PDF 格式，确保高分辨率
plt.savefig('cell_density_optimized_adjusted.pdf', dpi=300, format='pdf')

# 显示图形
plt.show()

```



## 2.2 R语言可视化

### 2.2.1 ggplot2基础

首先下载并安装R语言，，可参考https://cloud.r-project.org/。然后下载RStudio，参考https://posit.co/download/rstudio-desktop/。

在RStudio的界面当中，安装ggplot2库，也可以按住归纳上。

```r
# 安装ggplot2（如果尚未安装）
install.packages("ggplot2")

# 加载ggplot2包
library(ggplot2)

# 可选：加载dplyr包用于数据处理
install.packages("dplyr")
library(dplyr)

```
我们仍然从创建一个基础图形开始。在ggplot中，我们可以使用类似ggplot(data, aes(x, y))的方法，实现指定数据和美学映射。

```r
# 示例数据
time <- c(0, 2, 4, 6, 8, 10)  # 时间点（小时）
cell_density <- c(1.5, 3.0, 5.2, 8.0, 12.1, 15.0)  # 细胞密度（cells/mL）
error <- c(0.1, 0.2, 0.2, 0.3, 0.4, 0.5)  # 误差

# 创建数据框
data <- data.frame(time, cell_density, error)

# 基础折线图
ggplot(data, aes(x = time, y = cell_density)) +
  geom_line() +
  geom_point()

```

如果了解R语言基础语法的话可以发现，相比与matplotlib，ggplot2是基于图形语法的，更注重声明式绘图方式。



### 2.2.2 学术风格的优化


按照此前在matplotlib所述的优化，我们同样可以对ggplot2进行优化，包括：

减少网格线的干扰：使用细且浅色的网格线。
```r
ggplot(data, aes(x = time, y = cell_density)) +
  geom_line(color = "#1f77b4", size = 1.5) +
  geom_point(color = "#ff7f0e", size = 3) +
  geom_errorbar(aes(ymin = cell_density - error, ymax = cell_density + error),
                width = 0.2, color = "gray50", size = 0.5) +
  labs(title = "Cell Density Over Time",
       x = "Time (hours)",
       y = "Cell Density (cells/mL)") +
  theme_minimal(base_family = "Times New Roman") +
  theme(
    text = element_text(size = 12),
    plot.title = element_text(size = 14, face = "bold"),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10),
    panel.grid.major = element_line(color = "gray80", size = 0.5),
    panel.grid.minor = element_blank(),
    legend.position = "none"
  ) +
  xlim(0, 10) +
  ylim(0, 16) +
  geom_text(aes(label = cell_density),
            vjust = -0.5, size = 3, color = "#1f77b4")
```


选择专业配色：确保颜色对比度高且色盲友好。  


保持图形简洁：避免不必要的装饰性元素。  
优化标注：仅标注关键数据点或使用更智能的标注方法。

我们将所有

```r
library(ggplot2)
library(dplyr)

# 示例数据
time <- c(0, 2, 4, 6, 8, 10)
cell_density <- c(1.5, 3.0, 5.2, 8.0, 12.1, 15.0)
error <- c(0.1, 0.2, 0.2, 0.3, 0.4, 0.5)
data <- data.frame(time, cell_density, error)

# 创建图形
p <- ggplot(data, aes(x = time, y = cell_density)) +
  geom_line(color = "#1f77b4", size = 1.5) +
  geom_point(color = "#ff7f0e", size = 3) +
  geom_errorbar(aes(ymin = cell_density - error, ymax = cell_density + error),
                width = 0.2, color = "gray50", size = 0.5) +
  labs(title = "Cell Density Over Time",
       x = "Time (hours)",
       y = "Cell Density (cells/mL)") +
  theme_minimal(base_family = "Times New Roman") +
  theme(
    text = element_text(size = 12),
    plot.title = element_text(size = 14, face = "bold"),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10),
    panel.grid.major = element_line(color = "gray80", size = 0.5),
    panel.grid.minor = element_blank(),
    legend.position = "none"
  ) +
  xlim(0, 10) +
  ylim(0, 16) +
  geom_text(data = data %>% filter(cell_density == min(cell_density) | cell_density == max(cell_density)),
            aes(label = cell_density),
            vjust = -0.5, size = 3, color = "#1f77b4")

# 显示图形
print(p)

# 导出图形
ggsave("cell_density_optimized.pdf", plot = p, width = 6, height = 4, dpi = 300, device = cairo_pdf)

```




## 2.3 Python与R的整合

我们可以对比matplotlib与ggplot2在基本语法上的区别


<table style="border: 1px solid black; border-collapse: collapse; width: 100%;">
    <tr>
        <th style="border: 1px solid black; padding: 5px; text-align: left;">组件名称</th>
        <th style="border: 1px solid black; padding: 5px; text-align: left;">matplotlib</th>
        <th style="border: 1px solid black; padding: 5px; text-align: left;">ggplot2</th>
    </tr>
    <tr>
        <td style="border: 1px solid black; padding: 5px;">图形/图像</td>
        <td style="border: 1px solid black; padding: 5px;">通过 `plt.figure` 创建图形容器。</td>
        <td style="border: 1px solid black; padding: 5px;">通过 `ggplot()` 创建绘图对象。</td>
    </tr>
    <tr>
        <td style="border: 1px solid black; padding: 5px;">轴 (Axes)</td>
        <td style="border: 1px solid black; padding: 5px;">通过 `fig.subplots()` 创建轴对象。</td>
        <td style="border: 1px solid black; padding: 5px;">通过 `facet_wrap()` 或 `facet_grid()` 创建分面布局。</td>
    </tr>
    <tr>
        <td style="border: 1px solid black; padding: 5px;">线 (Line)</td>
        <td style="border: 1px solid black; padding: 5px;">通过 `ax.plot()` 绘制折线图。</td>
        <td style="border: 1px solid black; padding: 5px;">通过 `geom_line()` 绘制折线图。</td>
    </tr>
    <tr>
        <td style="border: 1px solid black; padding: 5px;">散点图点 (Markers)</td>
        <td style="border: 1px solid black; padding: 5px;">通过 `ax.scatter()` 绘制散点图。</td>
        <td style="border: 1px solid black; padding: 5px;">通过 `geom_point()` 绘制散点图。</td>
    </tr>
    <tr>
        <td style="border: 1px solid black; padding: 5px;">标题 (Title)</td>
        <td style="border: 1px solid black; padding: 5px;">通过 `ax.set_title()` 设置标题。</td>
        <td style="border: 1px solid black; padding: 5px;">通过 `ggtitle()` 设置标题。</td>
    </tr>
    <tr>
        <td style="border: 1px solid black; padding: 5px;">x轴</td>
        <td style="border: 1px solid black; padding: 5px;">通过 `ax.xaxis` 获取或修改 x 轴。</td>
        <td style="border: 1px solid black; padding: 5px;">通过 `scale_x_continuous()` 修改 x 轴。</td>
    </tr>
    <tr>
        <td style="border: 1px solid black; padding: 5px;">y轴</td>
        <td style="border: 1px solid black; padding: 5px;">通过 `ax.yaxis` 获取或修改 y 轴。</td>
        <td style="border: 1px solid black; padding: 5px;">通过 `scale_y_continuous()` 修改 y 轴。</td>
    </tr>
    <tr>
        <td style="border: 1px solid black; padding: 5px;">x轴标签 (xlabel)</td>
        <td style="border: 1px solid black; padding: 5px;">通过 `ax.set_xlabel()` 设置 x 轴标签。</td>
        <td style="border: 1px solid black; padding: 5px;">通过 `labs(x = "标签内容")` 设置 x 轴标签。</td>
    </tr>
    <tr>
        <td style="border: 1px solid black; padding: 5px;">y轴标签 (ylabel)</td>
        <td style="border: 1px solid black; padding: 5px;">通过 `ax.set_ylabel()` 设置 y 轴标签。</td>
        <td style="border: 1px solid black; padding: 5px;">通过 `labs(y = "标签内容")` 设置 y 轴标签。</td>
    </tr>
    <tr>
        <td style="border: 1px solid black; padding: 5px;">网格 (Grid)</td>
        <td style="border: 1px solid black; padding: 5px;">通过 `ax.grid()` 添加或修改网格线。</td>
        <td style="border: 1px solid black; padding: 5px;">通过 `theme()` 开启、关闭或调整网格线。</td>
    </tr>
    <tr>
        <td style="border: 1px solid black; padding: 5px;">图例 (Legend)</td>
        <td style="border: 1px solid black; padding: 5px;">通过 `ax.legend()` 创建或调整图例。</td>
        <td style="border: 1px solid black; padding: 5px;">通过 `labs()` 或 `theme()` 调整图例。</td>
    </tr>
    <tr>
        <td style="border: 1px solid black; padding: 5px;">主刻度 (Major ticks)</td>
        <td style="border: 1px solid black; padding: 5px;">通过 `ax.xaxis.set_major_locator()` 或 `ax.yaxis.set_major_locator()` 设置主刻度。</td>
        <td style="border: 1px solid black; padding: 5px;">通过 `scale_x_continuous()` 或 `scale_y_continuous()` 设置主刻度。</td>
    </tr>
    <tr>
        <td style="border: 1px solid black; padding: 5px;">次刻度 (Minor ticks)</td>
        <td style="border: 1px solid black; padding: 5px;">通过 `ax.xaxis.set_minor_locator()` 或 `ax.yaxis.set_minor_locator()` 设置次刻度。</td>
        <td style="border: 1px solid black; padding: 5px;">默认不支持次刻度，可通过扩展包或自定义刻度实现。</td>
    </tr>
    <tr>
        <td style="border: 1px solid black; padding: 5px;">刻度标签 (Tick labels)</td>
        <td style="border: 1px solid black; padding: 5px;">通过 `ax.xaxis.set_major_formatter()` 或 `ax.yaxis.set_major_formatter()` 设置刻度标签格式。</td>
        <td style="border: 1px solid black; padding: 5px;">通过 `scale_*` 系列函数设置刻度标签格式。</td>
    </tr>
    <tr>
        <td style="border: 1px solid black; padding: 5px;">边框 (Spine)</td>
        <td style="border: 1px solid black; padding: 5px;">通过 `ax.spines` 获取或修改边框。</td>
        <td style="border: 1px solid black; padding: 5px;">通过 `theme()` 修改边框样式或移除边框。</td>
    </tr>
</table>



对于一些复杂的数据，我们可以利用两者的联动来实现更加快速的可视化。

数据处理与初步探索（Python + Matplotlib）

在Python中进行大规模数据的预处理和初步可视化，利用Matplotlib的灵活性和交互式能力，快速识别数据中的模式和异常。


推荐阅读：

[The R Graph Gallery – Help and inspiration for R charts](https://r-graph-gallery.com)  
https://ggplot2-book.org/





















