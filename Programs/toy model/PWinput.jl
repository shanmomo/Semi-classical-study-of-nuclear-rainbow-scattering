## 分波法参数输入

## --------PHYSICAL_REVIEW C, VOLUME 62, 044601 ———————

# 重离子类型和能量
Mp,Zp = 16.0,8.0
Mt,Zt = 12.0,6.0
Elab = 132.0 # MeV
# Elab = 608.0

# 势参数
WSs = [
        [282.2, 0.586, 0.978, 13.86, 1.183, 0.656]  # 132
        # [216.3, 0.683, 0.927, 17.83, 1.219, 0.541]  # 200
        # [158.2, 0.703, 0.931, 23.97, 1.106, 0.646]  # 608
        ]   # 标准WS模型

# 求解范围
lmax = 200 #最高分波阶数
ρmax = 300. #最大无量纲半径，数值不应小于最高分波阶数

# 精度&步长
Sltol = 1e-8 # break, when |Sl-1|<Sltol
ρstep = 0.3 # unitless radius ρ step.
ρ0tolp1 = 0.3 # relative parameter for ρ_start
l_adaptive = true # if false, only break at l=lmax

## 参数计算
Ecm = Elab * Mt/(Mp+Mt)
μ = Mp*Mt/(Mp+Mt)*AMU
k = sqrt(2*Ecm*μ)/ħc
unitlessR = cbrt(Mp) + cbrt(Mt)
rmax = ρmax/k
# η = Zp*Zt*e²4πϵ*μ/(ħc^2*k)

## 势函数计算

# 核势 Wood-Saxon: [depth(MeV), width_factor(fm), skewness(fm)]
struct WSparams
    dV::Float64
    rV::Float64
    aV::Float64
    dW::Float64
    rW::Float64
    aW::Float64
end

function parseWSparams(WS)  # 约化参数并写成WSparams类型
    return WSparams((WS.*repeat([Ecm^-1, unitlessR, 1],2))...)  # 放入结构体需解包
end

function genericWS(r::Float64, P::WSparams)::ComplexF64
    return ComplexF64(
    -P.dV/(exp((r-P.rV)/P.aV)+1.),
    -P.dW/(exp((r-P.rW)/P.aW)+1.)
    )
end

WSp = parseWSparams.(WSs)

## 主程序中具体选取的势能，只能有一项V_Nuclear
V_Nuclear(r) = sum(genericWS.(r,WSp))
