import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/formatter.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/checkout_step.dart';

  enum PaymentMethod { bankTransfer, shopeePay, gopay, dana, ovo }
  enum BankOption {
    bni,
    bri,
    bca,
    mandiri,
    jago,
    seabank,
    permata,
    bsi,
    cimb
  }

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Form controllers
  final _shippingFormKey = GlobalKey<FormState>();
  
  // Shipping form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  
  // Payment form controllers
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildShippingStep(),
                _buildPaymentStep(),
                _buildReviewStep(),
              ],
            ),
          ),
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CheckoutStep(
            stepNumber: 1,
            title: 'Shipping',
            isActive: _currentStep == 0,
            isCompleted: _currentStep > 0,
          ),
          Expanded(
            child: Container(
              height: 2,
              color: _currentStep > 0 ? AppTheme.primaryColor : Colors.grey.shade300,
            ),
          ),
          CheckoutStep(
            stepNumber: 2,
            title: 'Payment',
            isActive: _currentStep == 1,
            isCompleted: _currentStep > 1,
          ),
          Expanded(
            child: Container(
              height: 2,
              color: _currentStep > 1 ? AppTheme.primaryColor : Colors.grey.shade300,
            ),
          ),
          CheckoutStep(
            stepNumber: 3,
            title: 'Review',
            isActive: _currentStep == 2,
            isCompleted: false,
          ),
        ],
      ),
    );
  }

  Widget _buildShippingStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _shippingFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shipping Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Street Address',
                prefixIcon: Icon(Icons.home),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _zipController,
              decoration: const InputDecoration(
                labelText: 'Post Code',
                prefixIcon: Icon(Icons.location_on),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter post code';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  PaymentMethod? _selectedPaymentMethod;
  BankOption? _selectedBank;

  Widget _buildPaymentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Metode Pembayaran',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Transfer Bank
          GestureDetector(
            onTap: () => setState(() => _selectedPaymentMethod = PaymentMethod.bankTransfer),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedPaymentMethod == PaymentMethod.bankTransfer
                      ? AppTheme.primaryColor
                      : Colors.grey.shade400,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance),
                  const SizedBox(width: 12),
                  const Expanded(child: Text("Transfer Bank")),
                  Icon(
                    Icons.arrow_drop_down,
                    color: _selectedPaymentMethod == PaymentMethod.bankTransfer
                        ? AppTheme.primaryColor
                        : Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          // List bank muncul kalau Transfer Bank dipilih
          if (_selectedPaymentMethod == PaymentMethod.bankTransfer)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: 250, // batasi tinggi maksimal agar bisa discroll
                ),
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: BankOption.values.map((bank) {
                    final bankNames = {
                      BankOption.bni: "Bank BNI",
                      BankOption.bri: "Bank BRI",
                      BankOption.bca: "Bank BCA",
                      BankOption.mandiri: "Bank Mandiri",
                      BankOption.jago: "Bank Jago",
                      BankOption.seabank: "SeaBank",
                      BankOption.permata: "Bank Permata",
                      BankOption.bsi: "Bank Syariah Indonesia",
                      BankOption.cimb: "Bank CIMB Niaga",
                    };
                    return RadioListTile<BankOption>(
                      dense: true,
                      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        bankNames[bank]!,
                        style: const TextStyle(fontSize: 13),
                      ),
                      value: bank,
                      groupValue: _selectedBank,
                      onChanged: (value) => setState(() => _selectedBank = value),
                    );
                  }).toList(),
                ),
              ),
            ),

          // Metode lain
          ...[
            PaymentMethod.shopeePay,
            PaymentMethod.gopay,
            PaymentMethod.dana,
            PaymentMethod.ovo,
          ].map((method) {
            final labels = {
              PaymentMethod.shopeePay: "ShopeePay",
              PaymentMethod.gopay: "Gopay",
              PaymentMethod.dana: "Dana",
              PaymentMethod.ovo: "OVO",
            };
            return GestureDetector(
              onTap: () => setState(() => _selectedPaymentMethod = method),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedPaymentMethod == method
                        ? AppTheme.primaryColor
                        : Colors.grey.shade400,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Radio<PaymentMethod>(
                      value: method,
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) => setState(() => _selectedPaymentMethod = value),
                      activeColor: AppTheme.primaryColor,
                      visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                    ),
                    const SizedBox(width: 4),
                    Text(labels[method]!),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }


  Widget _buildReviewStep() {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        final shipping = cart.totalAmount > 100 ? 0.0 : 9.99;
        final total = cart.totalAmount + shipping;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Order Review',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildOrderSummary(cart, shipping, total),
              const SizedBox(height: 24),
              _buildShippingInfo(),
              const SizedBox(height: 24),
              _buildPaymentInfo(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderSummary(CartProvider cart, double shipping, double total) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...cart.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text('${item.product.name} x${item.quantity}'),
                  ),
                  Text(formatRupiah(item.totalPrice)),
                ],
              ),
            )),
            const Divider(),
            Row(
              children: [
                const Expanded(child: Text('Subtotal:')),
                Text(formatRupiah(cart.totalAmount)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Expanded(child: Text('Shipping:')),
                Text(shipping == 0 ? 'Free' : formatRupiah(shipping)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  formatRupiah(total),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shipping Address',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(_nameController.text),
            Text(_addressController.text),
            Text('${_cityController.text}, ${_stateController.text} ${_zipController.text}'),
            Text(_phoneController.text),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo() {
    String paymentMethodText = '';
    IconData paymentIcon = Icons.payment;
    
    if (_selectedPaymentMethod != null) {
      switch (_selectedPaymentMethod!) {
        case PaymentMethod.bankTransfer:
          paymentMethodText = 'Transfer Bank';
          if (_selectedBank != null) {
            final bankNames = {
              BankOption.bni: "Bank BNI",
              BankOption.bri: "Bank BRI",
              BankOption.bca: "Bank BCA",
              BankOption.mandiri: "Bank Mandiri",
              BankOption.jago: "Bank Jago",
              BankOption.seabank: "SeaBank",
              BankOption.permata: "Bank Permata",
              BankOption.bsi: "Bank Syariah Indonesia",
              BankOption.cimb: "Bank CIMB Niaga",
            };
            paymentMethodText = bankNames[_selectedBank!]!;
          }
          paymentIcon = Icons.account_balance;
          break;
        case PaymentMethod.shopeePay:
          paymentMethodText = 'ShopeePay';
          paymentIcon = Icons.wallet;
          break;
        case PaymentMethod.gopay:
          paymentMethodText = 'Gopay';
          paymentIcon = Icons.wallet;
          break;
        case PaymentMethod.dana:
          paymentMethodText = 'Dana';
          paymentIcon = Icons.wallet;
          break;
        case PaymentMethod.ovo:
          paymentMethodText = 'OVO';
          paymentIcon = Icons.wallet;
          break;
      }
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(paymentIcon),
                const SizedBox(width: 8),
                Text(paymentMethodText.isEmpty ? 'Belum dipilih' : paymentMethodText),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Text('Back'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _handleNextStep,
                child: Text(_currentStep == 2 ? 'Place Order' : 'Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNextStep() {
    if (_currentStep == 0) {
      if (_shippingFormKey.currentState!.validate()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else if (_currentStep == 1) {
      // Ganti validasi form dengan validasi payment method
      if (_selectedPaymentMethod == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih metode pembayaran terlebih dahulu')),
        );
        return;
      }
      // Jika bank transfer dipilih, pastikan bank juga dipilih
      if (_selectedPaymentMethod == PaymentMethod.bankTransfer && _selectedBank == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih bank untuk transfer')),
        );
        return;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentStep == 2) {
      _placeOrder();
    }
  }

  void _placeOrder() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan masuk terlebih dahulu')),
      );
      return;
    }

    // Validate payment method
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih metode pembayaran terlebih dahulu')),
      );
      return;
    }

    if (_selectedPaymentMethod == PaymentMethod.bankTransfer && _selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih bank untuk transfer')),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final shipping = cartProvider.totalAmount > 100 ? 0.0 : 9.99;
      final total = cartProvider.totalAmount + shipping;

      // Prepare payment method string
      String paymentMethodText = '';
      String? bankName;
      
      switch (_selectedPaymentMethod!) {
        case PaymentMethod.bankTransfer:
          paymentMethodText = 'Transfer Bank';
          if (_selectedBank != null) {
            final bankNames = {
              BankOption.bni: "Bank BNI",
              BankOption.bri: "Bank BRI",
              BankOption.bca: "Bank BCA",
              BankOption.mandiri: "Bank Mandiri",
              BankOption.jago: "Bank Jago",
              BankOption.seabank: "SeaBank",
              BankOption.permata: "Bank Permata",
              BankOption.bsi: "Bank Syariah Indonesia",
              BankOption.cimb: "Bank CIMB Niaga",
            };
            bankName = bankNames[_selectedBank!];
          }
          break;
        case PaymentMethod.shopeePay:
          paymentMethodText = 'ShopeePay';
          break;
        case PaymentMethod.gopay:
          paymentMethodText = 'Gopay';
          break;
        case PaymentMethod.dana:
          paymentMethodText = 'Dana';
          break;
        case PaymentMethod.ovo:
          paymentMethodText = 'OVO';
          break;
      }

      // Prepare shipping address
      final shippingAddress = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'zipCode': _zipController.text.trim(),
      };

      // Create order in Firebase
      await orderProvider.createOrder(
        userId: authProvider.user!.id,
        items: cartProvider.items,
        totalAmount: total,
        shippingCost: shipping,
        paymentMethod: paymentMethodText,
        bankName: bankName,
        shippingAddress: shippingAddress,
      );

      Navigator.of(context).pop(); // Close loading dialog
      
      // Clear cart
      cartProvider.clearCart();
      
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Pesanan Berhasil!'),
          content: const Text('Pesanan Anda telah berhasil dibuat. Anda akan menerima email konfirmasi segera.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home',
                  (route) => false,
                ); // Go to home
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat pesanan: ${e.toString()}')),
      );
    }
  }
}
